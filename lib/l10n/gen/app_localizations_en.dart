// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class LEn extends L {
  LEn([String locale = 'en']) : super(locale);

  @override
  String get commonRefresh => 'Refresh';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonClose => 'Close';

  @override
  String get commonSave => 'Save';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonCreate => 'Create';

  @override
  String get commonLoading => 'Loading';

  @override
  String get commonCopied => 'Copied';

  @override
  String get commonAll => 'All';

  @override
  String get commonNoRecords => 'No records.';

  @override
  String get commonNoData => 'No data.';

  @override
  String get commonAnonymous => 'anonymous';

  @override
  String get commonError => 'Error';

  @override
  String get commonOwner => 'owner';

  @override
  String get commonMember => 'member';

  @override
  String get commonOpen => 'open';

  @override
  String get commonResolved => 'resolved';

  @override
  String get commonEnded => 'ended';

  @override
  String get commonEmpty => '—';

  @override
  String errNetwork(String endpoint) {
    return 'Cannot reach the server ($endpoint).';
  }

  @override
  String get errInvalidCredentials => 'Wrong email or password.';

  @override
  String get errSessionExpired =>
      'Your session has expired, please sign in again.';

  @override
  String get errOwnerRequired => 'You must be the project owner to do that.';

  @override
  String get errNotFound => 'Not found.';

  @override
  String get errEmailTaken => 'That email address is already registered.';

  @override
  String get errPasswordTooShort =>
      'The password must be at least 6 characters.';

  @override
  String get errInvalidEmail => 'Enter a valid email address.';

  @override
  String get errUnknownMember =>
      'Nobody is registered with that email address; they must sign up first.';

  @override
  String get errSelfRemove => 'You cannot remove yourself from the project.';

  @override
  String get errProjectNameRequired => 'A project name is required.';

  @override
  String get errUnsupportedLocale => 'That language is not supported.';

  @override
  String get errAlertChannelInvalid => 'Invalid notification channel details.';

  @override
  String get errAlertRuleInvalid => 'Invalid alert rule details.';

  @override
  String get errAlertSendFailed => 'Failed to send alert notification.';

  @override
  String get fmtJustNow => 'just now';

  @override
  String fmtMinutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minutes ago',
      one: '1 minute ago',
    );
    return '$_temp0';
  }

  @override
  String fmtHoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hours ago',
      one: '1 hour ago',
    );
    return '$_temp0';
  }

  @override
  String fmtDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days ago',
      one: '1 day ago',
    );
    return '$_temp0';
  }

  @override
  String fmtSeconds(int count) {
    return '${count}s';
  }

  @override
  String fmtMinutes(int count) {
    return '${count}m';
  }

  @override
  String fmtHours(String hours) {
    return '${hours}h';
  }

  @override
  String get fmtDateTimePattern => 'MMM d, yyyy HH:mm';

  @override
  String get fmtDayPattern => 'MMM dd';

  @override
  String get fmtClockPattern => 'HH:mm:ss';

  @override
  String get navOverview => 'Overview';

  @override
  String get navIssues => 'Issues';

  @override
  String get navSessions => 'Sessions';

  @override
  String get navReleases => 'Releases';

  @override
  String get navEvents => 'Events';

  @override
  String get navSettings => 'Settings';

  @override
  String get releasesTitle => 'Releases';

  @override
  String releasesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count releases',
      one: '1 release',
    );
    return '$_temp0';
  }

  @override
  String releasesLoadFailed(String error) {
    return 'Could not load releases: $error';
  }

  @override
  String get releasesEmpty => 'No release data yet.';

  @override
  String get colCrashFreeRate => 'Crash-Free %';

  @override
  String get colAdoption => 'Adoption %';

  @override
  String get colErrorSessions => 'Error Sessions';

  @override
  String get issueReleaseFirst => 'First release';

  @override
  String get issueReleaseLast => 'Last release';

  @override
  String get issueReleaseResolvedIn => 'Resolved in release';

  @override
  String shellSourceTooltip(String url) {
    return 'Source code: $url';
  }

  @override
  String get shellSignOut => 'Sign out';

  @override
  String get shellLanguage => 'Language';

  @override
  String get languageTurkish => 'Türkçe';

  @override
  String get languageEnglish => 'English';

  @override
  String get authSignIn => 'Sign in';

  @override
  String get authSignInSubtitle =>
      'Continue to the sightpane dashboard with your account.';

  @override
  String get authNoAccount => 'No account yet?';

  @override
  String get authGoRegister => 'Sign up';

  @override
  String get authRegisterTitle => 'Create an account';

  @override
  String get authRegisterSubtitle =>
      'Sign up, create your first project, hand the key to the SDK.';

  @override
  String get authHaveAccount => 'Already have an account?';

  @override
  String get authGoSignIn => 'Sign in';

  @override
  String get authRegister => 'Sign up';

  @override
  String get authEmail => 'Email';

  @override
  String get authEmailHint => 'name@company.com';

  @override
  String get authPassword => 'Password';

  @override
  String get authPasswordRepeat => 'Password (again)';

  @override
  String get authFullName => 'Full name';

  @override
  String get authFullNameHint => 'Jane Doe';

  @override
  String get authPasswordHint => 'at least 6 characters';

  @override
  String get authInvalidEmail => 'Enter a valid email address';

  @override
  String get authPasswordRequired => 'A password is required';

  @override
  String get authPasswordTooShort =>
      'The password must be at least 6 characters';

  @override
  String get authPasswordMismatch => 'The passwords do not match';

  @override
  String get projectsTitle => 'Projects';

  @override
  String projectsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count projects',
      one: '1 project',
    );
    return '$_temp0';
  }

  @override
  String get projectsNew => 'New project';

  @override
  String get projectsLoading => 'Loading projects';

  @override
  String projectsLoadFailed(String error) {
    return 'Could not load projects: $error';
  }

  @override
  String get projectsEmptyTitle => 'You have no projects yet.';

  @override
  String get projectsEmptyBody =>
      'Create a project, then hand its key and address to the SDK.';

  @override
  String get projectsCreateFirst => 'Create the first project';

  @override
  String projectKeyAndAge(String key, String age) {
    return 'key $key · $age';
  }

  @override
  String get projectStatSessions24h => 'Sessions 24h';

  @override
  String get projectStatErrors24h => 'Errors 24h';

  @override
  String get projectStatOpenIssues => 'Open groups';

  @override
  String projectCreated(String name) {
    return '$name created';
  }

  @override
  String get projectGoTo => 'Go to project';

  @override
  String get projectName => 'Project name';

  @override
  String get projectNameRequired => 'A project name is required';

  @override
  String get projectNameHint => 'Checkout app';

  @override
  String get projectPlatform => 'Platform';

  @override
  String get setupAddress => 'Address';

  @override
  String get setupApiKey => 'API key';

  @override
  String get setupTitle => 'Setup';

  @override
  String overviewSubtitle(int days) {
    return 'last $days days';
  }

  @override
  String overviewDaysShort(int days) {
    return '${days}d';
  }

  @override
  String get overviewStatsLoading => 'Loading statistics';

  @override
  String overviewStatsFailed(String error) {
    return 'Could not load statistics: $error';
  }

  @override
  String get overviewSessionsAndErrors => 'Sessions and errors';

  @override
  String get overviewSessionsAndErrorsNote =>
      'by day · amber sessions, red errors';

  @override
  String get overviewEvents => 'Events';

  @override
  String get overviewByDay => 'by day';

  @override
  String get overviewTopIssues => 'Most frequent errors';

  @override
  String get overviewNoOpenIssues => 'No open errors.';

  @override
  String get overviewPlatforms => 'Platforms';

  @override
  String get overviewReleases => 'Releases';

  @override
  String get overviewTopEvents => 'Most frequent events';

  @override
  String get kpiSessions => 'Sessions';

  @override
  String kpiVisitorsNote(String count) {
    return '$count visitors (user + IP + browser)';
  }

  @override
  String get kpiErrors => 'Errors';

  @override
  String kpiOpenGroupsNote(String count) {
    return '$count open groups';
  }

  @override
  String get kpiCrashFree => 'Crash-free sessions';

  @override
  String get kpiEvents => 'Events';

  @override
  String kpiFramesNote(String count) {
    return '$count replay frames';
  }

  @override
  String get livePages => 'Pages';

  @override
  String liveRouteCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count routes',
      one: '1 route',
    );
    return '$_temp0';
  }

  @override
  String get liveNoPages => 'No page is being viewed right now.';

  @override
  String get liveNoRoute => '(no route)';

  @override
  String livePeopleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count people',
      one: '1 person',
    );
    return '$_temp0';
  }

  @override
  String get liveViewers => 'Viewers';

  @override
  String liveWindow(int seconds) {
    return 'last ${seconds}s';
  }

  @override
  String get liveNoOpenSessions => 'No open sessions.';

  @override
  String liveMore(int count) {
    return '+$count more';
  }

  @override
  String get liveWaiting => 'Waiting for live data';

  @override
  String liveSummary(int people, int visitors) {
    return '$people online right now · $visitors visitors';
  }

  @override
  String get liveRefreshNote => 'refreshes every second';

  @override
  String get issuesTitle => 'Issues';

  @override
  String issuesOpenCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count open groups',
      one: '1 open group',
    );
    return '$_temp0';
  }

  @override
  String get issuesShowResolved => 'Show resolved';

  @override
  String get issuesGroups => 'Error groups';

  @override
  String get issuesGroupingNote =>
      'same exception + same stack frames means one group';

  @override
  String issuesLoadFailed(String error) {
    return 'Could not load errors: $error';
  }

  @override
  String get issuesEmpty => 'No errors.';

  @override
  String get colError => 'Error';

  @override
  String get colException => 'Exception';

  @override
  String get colCount => 'Count';

  @override
  String get colFirst => 'First';

  @override
  String get colLast => 'Last';

  @override
  String get colStatus => 'Status';

  @override
  String issueDetailFailed(String error) {
    return 'Could not load the error group: $error';
  }

  @override
  String issueSeenSummary(String count, String first, String last) {
    return '$count times · first $first · last $last';
  }

  @override
  String get issueReopen => 'Reopen';

  @override
  String get issueResolve => 'Resolve';

  @override
  String get issueResolvedToast => 'Marked as resolved';

  @override
  String get issueResolvedToastNote =>
      'It reopens automatically if seen again.';

  @override
  String get issueAssignee => 'Assignee';

  @override
  String get issueUnassigned => 'Unassigned';

  @override
  String get issueStatus => 'Status';

  @override
  String get issueStatusOpen => 'Open';

  @override
  String get issueStatusResolved => 'Resolved';

  @override
  String get issueStatusIgnored => 'Ignored';

  @override
  String get issueStatusSnoozed => 'Snoozed';

  @override
  String get issueActionIgnore => 'Ignore';

  @override
  String get issueActionSnooze => 'Snooze';

  @override
  String get issueSnoozeTitle => 'Snooze issue';

  @override
  String get issueSnoozeDuration => 'By duration';

  @override
  String get issueSnooze1Hour => '1 hour';

  @override
  String get issueSnooze24Hours => '24 hours';

  @override
  String get issueSnooze7Days => '7 days';

  @override
  String get issueSnoozeCount => 'By occurrence count';

  @override
  String get issueSnoozeCount10 => 'After 10 more occurrences';

  @override
  String get issueSnoozeCount50 => 'After 50 more occurrences';

  @override
  String get issueSnoozeCount100 => 'After 100 more occurrences';

  @override
  String get issueComments => 'Comments';

  @override
  String get issueCommentsEmpty => 'No comments yet.';

  @override
  String get issueCommentAdd => 'Add a comment...';

  @override
  String get issueCommentSend => 'Send';

  @override
  String get issueIgnoredToast => 'Issue marked as ignored';

  @override
  String get issueSnoozedToast => 'Issue snoozed';

  @override
  String get issueStack => 'Stack trace';

  @override
  String get issueNoStack => '(no stack trace)';

  @override
  String get issueStackSymbolicated => 'Mapped to source';

  @override
  String get issueStackRaw => 'Raw stack trace';

  @override
  String get issueStackUnresolved => 'not mapped';

  @override
  String get issueStackMinifiedHint =>
      'Minified build — upload a source map for this release';

  @override
  String get issueOccurrences => 'Occurrences';

  @override
  String issueOccurrencesNote(int count) {
    return 'last $count';
  }

  @override
  String get colTime => 'Time';

  @override
  String get colSession => 'Session';

  @override
  String get colRoute => 'Route';

  @override
  String get colFrame => 'Frame';

  @override
  String get colMessage => 'Message';

  @override
  String get sessionsTitle => 'Sessions';

  @override
  String sessionsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sessions',
      one: '1 session',
    );
    return '$_temp0';
  }

  @override
  String get sessionsUserFilterHint => 'user id';

  @override
  String get sessionsOnlyErrors => 'Only with errors';

  @override
  String get sessionsRecent => 'Recent sessions';

  @override
  String sessionsLoadFailed(String error) {
    return 'Could not load sessions: $error';
  }

  @override
  String get sessionsEmpty =>
      'No session matches this filter. If the SDK is connected, sessions appear here within seconds.';

  @override
  String get searchHint =>
      'e.g. release:1.0 browser:Chrome route:/pay props.plan:pro errors:true';

  @override
  String get searchFilterQuick => 'Quick Filters';

  @override
  String get searchClear => 'Clear';

  @override
  String searchInvalid(String error) {
    return 'Search query invalid: $error';
  }

  @override
  String get searchPlaceholderIssues =>
      'Search issues (e.g. title:boom resolved:false)';

  @override
  String get colUser => 'User';

  @override
  String get colIp => 'IP';

  @override
  String get colPlatform => 'Platform';

  @override
  String get colRelease => 'Release';

  @override
  String get colStart => 'Started';

  @override
  String get colDuration => 'Duration';

  @override
  String get colEvent => 'Event';

  @override
  String get sessionLoading => 'Loading session';

  @override
  String sessionLoadFailed(String error) {
    return 'Could not load the session: $error';
  }

  @override
  String get sessionReplay => 'Replay';

  @override
  String sessionFramesAndDuration(int frames, String duration) {
    return '$frames frames · $duration';
  }

  @override
  String get sessionTimeline => 'Timeline';

  @override
  String sessionItemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
    );
    return '$_temp0';
  }

  @override
  String get sessionNoItems => 'No items.';

  @override
  String sessionHeader(String id) {
    return 'Session $id';
  }

  @override
  String sessionFullscreenTitle(String id, String user) {
    return 'Session $id · $user';
  }

  @override
  String get replayNoFrames =>
      'This session has no frames (SightpaneReplay is not wrapped, or replay is off).';

  @override
  String get replayNoFramesGeneric =>
      'This session has no replay frames recorded (replay is disabled or not sent).';

  @override
  String replayDomPlayerTitle(int count) {
    return 'DOM Replay ($count events)';
  }

  @override
  String replayPosition(String position, String total) {
    return '$position / ${total}s';
  }

  @override
  String replayBuffer(int done, int total) {
    return 'buffer $done/$total';
  }

  @override
  String get replayFullscreenHint => 'ESC closes · space plays/pauses';

  @override
  String itemIssueLink(int id) {
    return 'Error group #$id';
  }

  @override
  String itemRoute(String route) {
    return 'route $route';
  }

  @override
  String get itemBreadcrumbsBefore => 'Steps before the error';

  @override
  String get eventsTitle => 'Events';

  @override
  String get eventsSubtitle => 'last 30 days';

  @override
  String get eventsTypes => 'Event types';

  @override
  String eventsLoadFailed(String error) {
    return 'Could not load events: $error';
  }

  @override
  String get eventsEmpty => 'No events. Call Hog.capture(’event’) in the SDK.';

  @override
  String get colTotal => 'Total';

  @override
  String get settingsTitle => 'Settings';

  @override
  String settingsProjectLoadFailed(String error) {
    return 'Could not load the project: $error';
  }

  @override
  String get settingsProject => 'Project';

  @override
  String get settingsMemberReadOnly => 'member · read only';

  @override
  String get settingsProjectNameLabel => 'Name';

  @override
  String get settingsSaved => 'Saved';

  @override
  String get settingsRotateKey => 'Rotate the key';

  @override
  String get settingsRotateKeyBody =>
      'Apps still sending the old key will be rejected. You must put the new key into the SDK configuration.';

  @override
  String get settingsRotate => 'Rotate';

  @override
  String get settingsSdkSetup => 'SDK setup';

  @override
  String get settingsSdkSetupNote => 'endpoint and apiKey are passed at init';

  @override
  String get settingsMembers => 'Members';

  @override
  String get settingsMemberRemoved => 'Member removed';

  @override
  String get settingsMemberAdded => 'Member added';

  @override
  String get settingsAddMember => 'Add member';

  @override
  String get settingsMemberEmailHint =>
      'member@company.com (must be registered)';

  @override
  String get settingsAlertsTitle => 'Alerts & Notifications';

  @override
  String get settingsAlertChannels => 'Notification Channels';

  @override
  String get settingsAlertChannelsEmpty =>
      'No notification channels added yet.';

  @override
  String get settingsAlertChannelAdd => 'Add channel';

  @override
  String get settingsAlertChannelName => 'Channel name';

  @override
  String get settingsAlertChannelKind => 'Channel kind';

  @override
  String get settingsAlertChannelTarget => 'Target';

  @override
  String get settingsAlertChannelTargetHint => 'Email, Slack, or Webhook URL';

  @override
  String get settingsAlertChannelSecret => 'Secret key';

  @override
  String get settingsAlertChannelSecretHint =>
      'Optional HMAC secret for webhooks';

  @override
  String get settingsAlertChannelTest => 'Send test';

  @override
  String get settingsAlertChannelTestSuccess =>
      'Test notification sent successfully.';

  @override
  String get settingsAlertChannelDeleteConfirm =>
      'Are you sure you want to delete this notification channel?';

  @override
  String get settingsAlertRules => 'Alert Rules';

  @override
  String get settingsAlertRulesEmpty => 'No alert rules added yet.';

  @override
  String get settingsAlertRuleAdd => 'Add rule';

  @override
  String get settingsAlertRuleName => 'Rule name';

  @override
  String get settingsAlertRuleKind => 'Event kind';

  @override
  String get settingsAlertRuleKindNewIssue => 'New issue';

  @override
  String get settingsAlertRuleKindRegression => 'Regressed issue';

  @override
  String get settingsAlertRuleKindRateSpike => 'Error rate spike';

  @override
  String get settingsAlertRuleKindCrashFree => 'Crash-free rate drop';

  @override
  String get settingsAlertRuleChannels => 'Channels';

  @override
  String get settingsAlertRuleChannelsSelectHint =>
      'Select at least one channel';

  @override
  String get settingsAlertRuleThreshold => 'Threshold';

  @override
  String get settingsAlertRuleWindow => 'Time window (minutes)';

  @override
  String get settingsAlertRuleEnabled => 'Enabled';

  @override
  String get settingsAlertRuleDeleteConfirm =>
      'Are you sure you want to delete this alert rule?';

  @override
  String get settingsDangerZone => 'Danger zone';

  @override
  String get settingsDeleteBody =>
      'Permanently deletes the project and all its session, error and frame data.';

  @override
  String get settingsDeleteProject => 'Delete project';

  @override
  String settingsDeleteConfirmTitle(String name) {
    return 'Delete \"$name\"?';
  }

  @override
  String get settingsDeleteConfirmBody => 'This cannot be undone.';

  @override
  String get performanceTitle => 'Performance';

  @override
  String performanceSubtitle(int count) {
    return '$count operations tracked';
  }

  @override
  String get performanceEmpty => 'No performance data yet.';

  @override
  String performanceLoadFailed(String error) {
    return 'Failed to load performance data: $error';
  }

  @override
  String get colOperation => 'Operation';

  @override
  String get colTransaction => 'Transaction';

  @override
  String get colP50 => 'p50';

  @override
  String get colP95 => 'p95';

  @override
  String get colAvg => 'Avg';

  @override
  String get colCalls => 'Calls';

  @override
  String get colErrorRate => 'Error %';

  @override
  String get performanceSlowestSamples => 'Slowest Samples';

  @override
  String get performanceViewReplay => 'View Replay';

  @override
  String get performanceDays7 => 'Last 7 Days';

  @override
  String get performanceDays14 => 'Last 14 Days';

  @override
  String get performanceDays30 => 'Last 30 Days';
}
