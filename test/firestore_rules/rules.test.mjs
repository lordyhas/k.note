import { readFileSync } from 'node:fs';
import { after, before, beforeEach, describe, test } from 'node:test';
import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from '@firebase/rules-unit-testing';
import {
  deleteDoc,
  doc,
  getDoc,
  getDocs,
  collection,
  setDoc,
  updateDoc,
  Timestamp,
  setLogLevel,
} from 'firebase/firestore';

const USERS = 'K_NOTE/general_data/USERS';
const ALICE = 'alice';
const BOB = 'bob';

let env;

const db = (uid, claims = {}) =>
  env.authenticatedContext(uid, { email: `${uid}@example.com`, ...claims }).firestore();

const note = (id, extra = {}) => ({
  id,
  title: 'Title',
  text: '[{"insert":"hello\\n"}]',
  creation_time: Timestamp.now(),
  last_time: Timestamp.now(),
  is_deleted: false,
  permanent_delete_date: null,
  color: 4278238420,
  reminder_date: null,
  is_archived: false,
  email: 'alice@example.com',
  is_locked: false,
  saving_mode: 0,
  ...extra,
});

const task = (id, extra = {}) => ({
  id,
  title: 'Groceries',
  is_all_checked: false,
  list: [{ text: 'Milk', is_done: false }],
  color: 4294967295,
  creation_time: Timestamp.now(),
  last_time: Timestamp.now(),
  is_important: false,
  is_my_day: false,
  due_date: null,
  reminder_time: null,
  repeat: null,
  note: null,
  ...extra,
});

const profile = (uid, extra = {}) => ({
  id: uid,
  name: 'Alice',
  email: `${uid}@example.com`,
  photo_mail: null,
  creation_time: Timestamp.now(),
  last_login: Timestamp.now(),
  ...extra,
});

/** Writes [data] at [path] bypassing the rules, e.g. to seed legacy data. */
const seed = (path, data) =>
  env.withSecurityRulesDisabled((ctx) => setDoc(doc(ctx.firestore(), path), data));

// Denied requests are expected here; keep the output readable.
setLogLevel('silent');

before(async () => {
  env = await initializeTestEnvironment({
    projectId: 'demo-knote',
    firestore: { rules: readFileSync(new URL('../../firestore.rules', import.meta.url), 'utf8') },
  });
});

beforeEach(() => env.clearFirestore());

after(() => env.cleanup());

describe('ownership', () => {
  test('signed-out users cannot read anything', async () => {
    await seed(`${USERS}/${ALICE}/notes/n1`, note('n1'));
    const anon = env.unauthenticatedContext().firestore();
    await assertFails(getDoc(doc(anon, `${USERS}/${ALICE}/notes/n1`)));
  });

  test('a user can create, read, update and delete their own note', async () => {
    const ref = doc(db(ALICE), `${USERS}/${ALICE}/notes/n1`);
    await assertSucceeds(setDoc(ref, note('n1')));
    await assertSucceeds(getDoc(ref));
    await assertSucceeds(updateDoc(ref, { title: 'New', text: 'x', last_time: Timestamp.now() }));
    await assertSucceeds(deleteDoc(ref));
  });

  test("a user cannot read another user's notes, even with a modified app", async () => {
    await seed(`${USERS}/${ALICE}/notes/n1`, note('n1'));
    const bob = db(BOB);
    await assertFails(getDoc(doc(bob, `${USERS}/${ALICE}/notes/n1`)));
    await assertFails(getDocs(collection(bob, `${USERS}/${ALICE}/notes`)));
    await assertFails(getDocs(collection(bob, USERS)));
  });

  test("a user cannot write or delete another user's data", async () => {
    await seed(`${USERS}/${ALICE}/notes/n1`, note('n1'));
    const bob = db(BOB);
    await assertFails(setDoc(doc(bob, `${USERS}/${ALICE}/notes/n2`), note('n2')));
    await assertFails(updateDoc(doc(bob, `${USERS}/${ALICE}/notes/n1`), { title: 'pwned' }));
    await assertFails(deleteDoc(doc(bob, `${USERS}/${ALICE}/notes/n1`)));
    await assertFails(setDoc(doc(bob, `${USERS}/${ALICE}/tasks/t1`), task('t1')));
  });

  test('paths outside the user subtree are denied', async () => {
    const alice = db(ALICE);
    await assertFails(getDocs(collection(alice, 'K_NOTE')));
    await assertFails(setDoc(doc(alice, 'K_NOTE/general_data'), { a: 1 }));
    await assertFails(setDoc(doc(alice, `${USERS}/${ALICE}/keys/master_key`), { k: 1 }));
  });
});

describe('blocked users', () => {
  test('the blocked custom claim cuts off all access', async () => {
    await seed(`${USERS}/${ALICE}/notes/n1`, note('n1'));
    const blocked = db(ALICE, { blocked: true });
    await assertFails(getDoc(doc(blocked, `${USERS}/${ALICE}/notes/n1`)));
    await assertFails(setDoc(doc(blocked, `${USERS}/${ALICE}/notes/n2`), note('n2')));
  });

  test('a user cannot unblock themselves through their profile', async () => {
    const ref = doc(db(ALICE), `${USERS}/${ALICE}`);
    await assertFails(setDoc(ref, profile(ALICE, { isBlocked: false })));
    await assertFails(setDoc(ref, profile(ALICE, { verified_account: true })));
  });
});

describe('profile', () => {
  test('a user can save a profile with the allowed fields', async () => {
    await assertSucceeds(setDoc(doc(db(ALICE), `${USERS}/${ALICE}`), profile(ALICE)));
  });

  test('the profile id and email must match the auth token', async () => {
    const ref = doc(db(ALICE), `${USERS}/${ALICE}`);
    await assertFails(setDoc(ref, profile(ALICE, { id: BOB })));
    await assertFails(setDoc(ref, profile(ALICE, { email: 'someone@else.com' })));
  });

  test('a legacy profile with extra fields can still be updated', async () => {
    await seed(`${USERS}/${ALICE}`, { ...profile(ALICE), isBlocked: false, location: null });
    const ref = doc(db(ALICE), `${USERS}/${ALICE}`);
    await assertSucceeds(updateDoc(ref, { last_login: Timestamp.now() }));
    await assertFails(updateDoc(ref, { isBlocked: true }));
  });
});

describe('note validation', () => {
  const ref = () => doc(db(ALICE), `${USERS}/${ALICE}/notes/n1`);

  test('unknown fields are rejected', async () => {
    await assertFails(setDoc(ref(), note('n1', { owner: BOB })));
  });

  test('the stored id must match the document id', async () => {
    await assertFails(setDoc(ref(), note('other')));
  });

  test('fields must have the expected types', async () => {
    await assertFails(setDoc(ref(), note('n1', { is_deleted: 'yes' })));
    await assertFails(setDoc(ref(), note('n1', { title: 42 })));
    await assertFails(setDoc(ref(), note('n1', { last_time: 'today' })));
  });

  test('the id cannot be changed after creation', async () => {
    await seed(`${USERS}/${ALICE}/notes/n1`, note('n1'));
    await assertFails(updateDoc(ref(), { id: 'n2' }));
  });

  test('a legacy note with extra fields can be updated and overwritten', async () => {
    await seed(`${USERS}/${ALICE}/notes/n1`, { ...note('n1'), cipher_iv: 'abc' });
    await assertSucceeds(updateDoc(ref(), { is_deleted: true }));
    await assertSucceeds(setDoc(ref(), note('n1')));
  });
});

describe('task validation', () => {
  const ref = () => doc(db(ALICE), `${USERS}/${ALICE}/tasks/t1`);

  test('a valid task can be written', async () => {
    await assertSucceeds(setDoc(ref(), task('t1')));
  });

  test('a task needs a string title and a list', async () => {
    await assertFails(setDoc(ref(), task('t1', { title: null })));
    await assertFails(setDoc(ref(), task('t1', { list: 'Milk' })));
  });

  test('unknown fields are rejected', async () => {
    await assertFails(setDoc(ref(), task('t1', { shared_with: [BOB] })));
  });
});
