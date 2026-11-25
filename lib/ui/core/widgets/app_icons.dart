import 'package:flutter/widgets.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart' as iconoir;

/// The app's icons, drawn from Iconoir (https://iconoir.com, MIT).
///
/// Pages use [AppIcon] with one of these values instead of Material [Icons],
/// so the whole app shares one stroke style. Iconoir's classes are only
/// imported here: several of their names (`Text`, `List`, `Page`...) clash
/// with Flutter's.
enum AppIcons {
  add,
  archive,
  arrowUp,
  arrowRightCircle,
  attachment,
  back,
  bell,
  bold,
  book,
  bookmark,
  building,
  calendar,
  calendarCheck,
  chat,
  check,
  checkCircle,
  checkCircleSolid,
  checklist,
  chevronDown,
  chevronLeft,
  chevronRight,
  chevronUp,
  circle,
  clock,
  close,
  cloudCheck,
  edit,
  eye,
  eyeClosed,
  folder,
  folderPlus,
  gift,
  google,
  grid,
  group,
  home,
  info,
  italic,
  language,
  list,
  listBullets,
  listNumbers,
  lock,
  logIn,
  logOut,
  mail,
  mapPin,
  minus,
  more,
  newNote,
  notes,
  openExternal,
  palette,
  quote,
  redo,
  refresh,
  repeat,
  search,
  send,
  settings,
  star,
  starSolid,
  strikethrough,
  suitcase,
  sun,
  task,
  text,
  textBox,
  textSize,
  trash,
  underline,
  undo,
  user,
  userCircle,
  userRemove,
  warning,
}

/// An [AppIcons] icon, sized and colored like an [Icon]: by [size] and
/// [color], or else by the surrounding [IconTheme] (so it follows the
/// selected and disabled states of buttons and navigation bars).
class AppIcon extends StatelessWidget {
  const AppIcon(this.icon, {super.key, this.size, this.color});

  final AppIcons icon;
  final double? size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = IconTheme.of(context);
    final size = this.size ?? theme.size ?? 24;
    var color = this.color ?? theme.color ?? const Color(0xFFFFFFFF);
    final opacity = theme.opacity;
    if (this.color == null && opacity != null && opacity < 1) {
      color = color.withValues(alpha: color.a * opacity);
    }
    return SizedBox.square(
      dimension: size,
      child: Center(child: _build(color, size)),
    );
  }

  Widget _build(Color c, double s) => switch (icon) {
        AppIcons.add => iconoir.Plus(color: c, width: s, height: s),
        AppIcons.archive => iconoir.Archive(color: c, width: s, height: s),
        AppIcons.arrowUp => iconoir.ArrowUp(color: c, width: s, height: s),
        AppIcons.arrowRightCircle =>
          iconoir.ArrowRightCircle(color: c, width: s, height: s),
        AppIcons.attachment =>
          iconoir.Attachment(color: c, width: s, height: s),
        AppIcons.back => iconoir.NavArrowLeft(color: c, width: s, height: s),
        AppIcons.bell => iconoir.Bell(color: c, width: s, height: s),
        AppIcons.bold => iconoir.Bold(color: c, width: s, height: s),
        AppIcons.book => iconoir.OpenBook(color: c, width: s, height: s),
        AppIcons.bookmark => iconoir.Bookmark(color: c, width: s, height: s),
        AppIcons.building => iconoir.Building(color: c, width: s, height: s),
        AppIcons.calendar => iconoir.Calendar(color: c, width: s, height: s),
        AppIcons.calendarCheck =>
          iconoir.CalendarCheck(color: c, width: s, height: s),
        AppIcons.chat => iconoir.ChatBubble(color: c, width: s, height: s),
        AppIcons.check => iconoir.Check(color: c, width: s, height: s),
        AppIcons.checkCircle =>
          iconoir.CheckCircle(color: c, width: s, height: s),
        AppIcons.checkCircleSolid =>
          iconoir.CheckCircleSolid(color: c, width: s, height: s),
        AppIcons.checklist =>
          iconoir.CheckSquare(color: c, width: s, height: s),
        AppIcons.chevronDown =>
          iconoir.NavArrowDown(color: c, width: s, height: s),
        AppIcons.chevronLeft =>
          iconoir.NavArrowLeft(color: c, width: s, height: s),
        AppIcons.chevronRight =>
          iconoir.NavArrowRight(color: c, width: s, height: s),
        AppIcons.chevronUp => iconoir.NavArrowUp(color: c, width: s, height: s),
        AppIcons.circle => iconoir.Circle(color: c, width: s, height: s),
        AppIcons.clock => iconoir.Clock(color: c, width: s, height: s),
        AppIcons.close => iconoir.Xmark(color: c, width: s, height: s),
        AppIcons.cloudCheck =>
          iconoir.CloudCheck(color: c, width: s, height: s),
        AppIcons.edit => iconoir.EditPencil(color: c, width: s, height: s),
        AppIcons.eye => iconoir.Eye(color: c, width: s, height: s),
        AppIcons.eyeClosed => iconoir.EyeClosed(color: c, width: s, height: s),
        AppIcons.folder => iconoir.Folder(color: c, width: s, height: s),
        AppIcons.folderPlus =>
          iconoir.FolderPlus(color: c, width: s, height: s),
        AppIcons.gift => iconoir.Gift(color: c, width: s, height: s),
        AppIcons.google => iconoir.Google(color: c, width: s, height: s),
        AppIcons.grid => iconoir.ViewGrid(color: c, width: s, height: s),
        AppIcons.group => iconoir.Group(color: c, width: s, height: s),
        AppIcons.home => iconoir.HomeSimple(color: c, width: s, height: s),
        AppIcons.info => iconoir.InfoCircle(color: c, width: s, height: s),
        AppIcons.italic => iconoir.Italic(color: c, width: s, height: s),
        AppIcons.language => iconoir.Language(color: c, width: s, height: s),
        AppIcons.list => iconoir.List(color: c, width: s, height: s),
        AppIcons.listBullets => iconoir.List(color: c, width: s, height: s),
        AppIcons.listNumbers =>
          iconoir.NumberedListLeft(color: c, width: s, height: s),
        AppIcons.lock => iconoir.Lock(color: c, width: s, height: s),
        AppIcons.logIn => iconoir.LogIn(color: c, width: s, height: s),
        AppIcons.logOut => iconoir.LogOut(color: c, width: s, height: s),
        AppIcons.mail => iconoir.Mail(color: c, width: s, height: s),
        AppIcons.mapPin => iconoir.MapPin(color: c, width: s, height: s),
        AppIcons.minus => iconoir.Minus(color: c, width: s, height: s),
        AppIcons.more => iconoir.MoreVert(color: c, width: s, height: s),
        AppIcons.newNote => iconoir.PagePlus(color: c, width: s, height: s),
        AppIcons.notes => iconoir.Notes(color: c, width: s, height: s),
        AppIcons.openExternal =>
          iconoir.OpenNewWindow(color: c, width: s, height: s),
        AppIcons.palette => iconoir.Palette(color: c, width: s, height: s),
        AppIcons.quote => iconoir.Quote(color: c, width: s, height: s),
        AppIcons.redo => iconoir.Redo(color: c, width: s, height: s),
        AppIcons.refresh => iconoir.Refresh(color: c, width: s, height: s),
        AppIcons.repeat => iconoir.Repeat(color: c, width: s, height: s),
        AppIcons.search => iconoir.Search(color: c, width: s, height: s),
        AppIcons.send => iconoir.Send(color: c, width: s, height: s),
        AppIcons.settings => iconoir.Settings(color: c, width: s, height: s),
        AppIcons.star => iconoir.Star(color: c, width: s, height: s),
        AppIcons.starSolid => iconoir.StarSolid(color: c, width: s, height: s),
        AppIcons.strikethrough =>
          iconoir.Strikethrough(color: c, width: s, height: s),
        AppIcons.suitcase => iconoir.Suitcase(color: c, width: s, height: s),
        AppIcons.sun => iconoir.SunLight(color: c, width: s, height: s),
        AppIcons.task => iconoir.TaskList(color: c, width: s, height: s),
        AppIcons.text => iconoir.Text(color: c, width: s, height: s),
        AppIcons.textBox => iconoir.TextBox(color: c, width: s, height: s),
        AppIcons.textSize => iconoir.TextSize(color: c, width: s, height: s),
        AppIcons.trash => iconoir.Trash(color: c, width: s, height: s),
        AppIcons.underline => iconoir.Underline(color: c, width: s, height: s),
        AppIcons.undo => iconoir.Undo(color: c, width: s, height: s),
        AppIcons.user => iconoir.User(color: c, width: s, height: s),
        AppIcons.userCircle =>
          iconoir.UserCircle(color: c, width: s, height: s),
        AppIcons.userRemove => iconoir.UserXmark(color: c, width: s, height: s),
        AppIcons.warning =>
          iconoir.WarningCircle(color: c, width: s, height: s),
      };
}
