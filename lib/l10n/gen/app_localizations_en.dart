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
  String get commonApply => 'Apply';

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
  String get navUsers => 'Users';

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
  String get filterByField => 'FILTER BY FIELD';

  @override
  String get filterValues => 'SELECT VALUE';

  @override
  String get filterBrowserDesc => 'Filter by browser';

  @override
  String get filterPlatformDesc => 'Filter by platform';

  @override
  String get filterReleaseDesc => 'Filter by release version';

  @override
  String get filterRouteDesc => 'Filter by route';

  @override
  String get filterUserDesc => 'Filter by user ID or email';

  @override
  String get filterOsDesc => 'Filter by operating system';

  @override
  String get filterErrorsDesc => 'Filter by error state';

  @override
  String get filterStatusDesc => 'Filter by status';

  @override
  String get filterAssigneeDesc => 'Filter by assignee';

  @override
  String get filterTitleDesc => 'Filter by title';

  @override
  String get filterExceptionDesc => 'Filter by exception';

  @override
  String get filterResolvedDesc => 'Filter by resolved status';

  @override
  String get colUser => 'User';

  @override
  String get colIp => 'IP';

  @override
  String get colLocation => 'Location';

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
  String get sessionClientInfo => 'Client & Environment Info';

  @override
  String get clientPlatform => 'Platform';

  @override
  String get clientPlatformDesktop => 'Desktop';

  @override
  String get clientPlatformWeb => 'Web';

  @override
  String get clientPlatformMobile => 'Mobile';

  @override
  String get clientDevice => 'Device';

  @override
  String get clientOS => 'Operating System';

  @override
  String get clientOsVersion => 'OS Version';

  @override
  String get clientKernel => 'Kernel';

  @override
  String get clientKernelVersion => 'Kernel Version';

  @override
  String get clientBrowser => 'Browser';

  @override
  String get clientBrowserVersion => 'Browser Version';

  @override
  String get clientArch => 'Architecture';

  @override
  String get clientCores => 'CPU Cores';

  @override
  String get clientScreen => 'Screen Resolution';

  @override
  String get clientLocale => 'Locale';

  @override
  String get clientLocation => 'Location';

  @override
  String get clientCoordinates => 'Coordinates';

  @override
  String get clientSdk => 'SDK';

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
  String get colAction => 'Action';

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

  @override
  String get usersTitle => 'Users';

  @override
  String usersSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count users',
      one: '1 user',
    );
    return '$_temp0';
  }

  @override
  String get usersSearchPlaceholder => 'Search user or email...';

  @override
  String usersLoadFailed(String error) {
    return 'Could not load users: $error';
  }

  @override
  String get usersEmpty => 'No users found.';

  @override
  String get kpiTotalUsers => 'Total Users';

  @override
  String get kpiActiveUsers => 'Active Users (Period)';

  @override
  String get kpiAvgDuration => 'Avg Session Duration';

  @override
  String get kpiSessionsPerUser => 'Sessions / User';

  @override
  String get chartActiveUsers => 'Daily Active Users (DAU)';

  @override
  String get chartActiveUsersSub =>
      'blue active users · red error-affected users';

  @override
  String get colAvgDuration => 'Avg Duration';

  @override
  String get colFirstSeen => 'First Seen';

  @override
  String get colLastSeen => 'Last Seen';

  @override
  String get userDetailTitle => 'User Details';

  @override
  String get actionViewSessions => 'View Sessions';

  @override
  String get actionExportData => 'Export Data (JSON)';

  @override
  String get actionDeleteData => 'Delete User Data';

  @override
  String get userDeleteConfirm =>
      'Delete all sessions and error records for this user?';

  @override
  String get userDeleteSuccess => 'User data deleted successfully.';

  @override
  String get userCustomProps => 'Custom Attributes';

  @override
  String get usersVisitorMapTitle => 'Visitor Map';

  @override
  String get usersVisitorMapSub =>
      'Geographic distribution of visitors based on GeoIP';

  @override
  String get usersMapNoData => 'No location data recorded for this period.';

  @override
  String usersMapVisitorsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count visitors',
      one: '1 visitor',
    );
    return '$_temp0';
  }

  @override
  String usersMapLocationsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count locations',
      one: '1 location',
    );
    return '$_temp0';
  }

  @override
  String get usersMapResetView => 'Reset View';

  @override
  String get usersMapZoomIn => 'Zoom In';

  @override
  String get usersMapZoomOut => 'Zoom Out';

  @override
  String get navFunnels => 'Funnels';

  @override
  String get funnelsTitle => 'Conversion Funnels';

  @override
  String funnelsSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count funnels defined',
      one: '1 funnel defined',
    );
    return '$_temp0';
  }

  @override
  String get funnelCreate => 'Create Funnel';

  @override
  String get funnelName => 'Funnel Name';

  @override
  String get funnelDescription => 'Description';

  @override
  String get funnelSteps => 'Funnel Steps';

  @override
  String get funnelStepAdd => 'Add Step';

  @override
  String get funnelStepEvent => 'Event Name';

  @override
  String get funnelWindow => 'Conversion Window';

  @override
  String get funnelWindow1d => '1 Day';

  @override
  String get funnelWindow7d => '7 Days';

  @override
  String get funnelWindow14d => '14 Days';

  @override
  String get funnelWindow30d => '30 Days';

  @override
  String get funnelsEmpty => 'No conversion funnels defined yet.';

  @override
  String get funnelsEmptyHint =>
      'Create your first funnel to track conversion and drop-off rates along user journeys.';

  @override
  String get funnelOverallConversion => 'Overall Conversion Rate';

  @override
  String get funnelCompletedSessions => 'Completed Sessions';

  @override
  String get funnelTotalSessions => 'Started Sessions';

  @override
  String get funnelMedianTime => 'Median Conversion Time';

  @override
  String get funnelStepConversion => 'Step Conversion';

  @override
  String get funnelDropOff => 'Drop-off';

  @override
  String funnelWatchReplays(int count) {
    return 'Watch Drop-off Replays ($count)';
  }

  @override
  String get funnelDeleteConfirm =>
      'Are you sure you want to delete this funnel?';

  @override
  String get funnelDeleted => 'Funnel deleted.';

  @override
  String get funnelCreated => 'Funnel created.';

  @override
  String get funnelUpdated => 'Funnel updated.';

  @override
  String get funnelStepMin => 'At least 2 steps are required.';

  @override
  String get navRetention => 'Retention';

  @override
  String get navCohorts => 'Cohorts';

  @override
  String get retentionTitle => 'User Retention Matrix';

  @override
  String get retentionSubtitle =>
      'Analyze how cohorts of users return to your application over time.';

  @override
  String get retentionPeriodDay => 'Daily';

  @override
  String get retentionPeriodWeek => 'Weekly';

  @override
  String get retentionTargetEvent => 'Target Event (Initial)';

  @override
  String get retentionReturnEvent => 'Return Event';

  @override
  String get retentionAllUsers => 'All Users';

  @override
  String get retentionCohortFilter => 'Cohort Filter';

  @override
  String get retentionHeatmapTitle => 'Retention Heatmap';

  @override
  String get retentionBucket => 'Cohort Date';

  @override
  String get retentionUsers => 'Users';

  @override
  String retentionPeriodN(String unit, int index) {
    return '$unit $index';
  }

  @override
  String get retentionEmpty =>
      'No retention data found for the selected range.';

  @override
  String get cohortsTitle => 'Behavioral Cohorts';

  @override
  String get cohortsSubtitle =>
      'Segment users by behavioral patterns and event frequency.';

  @override
  String get newCohort => 'New Cohort';

  @override
  String get cohortName => 'Cohort Name';

  @override
  String get cohortDescription => 'Description';

  @override
  String get cohortRules => 'Dynamic Rules';

  @override
  String get cohortDynamic => 'Dynamic';

  @override
  String get cohortStatic => 'Static';

  @override
  String get cohortMemberCount => 'Member Count';

  @override
  String get refreshCohort => 'Refresh Cohort';

  @override
  String get cohortRefreshed => 'Cohort members refreshed.';

  @override
  String get cohortCreated => 'Cohort created.';

  @override
  String get cohortDeleted => 'Cohort deleted.';

  @override
  String get cohortDeleteConfirm =>
      'Are you sure you want to delete this cohort?';

  @override
  String get cohortEmpty => 'No cohorts defined yet.';

  @override
  String get cohortEmptyHint =>
      'Create your first cohort to group users by their actions.';

  @override
  String get cohortAddRule => 'Add Rule';

  @override
  String get cohortEventName => 'Event Name';

  @override
  String get cohortOperator => 'Operator';

  @override
  String get cohortValue => 'Value';

  @override
  String get cohortWindowDays => 'Window (Days)';

  @override
  String get navPaths => 'User Paths';

  @override
  String get pathsTitle => 'User Journey Flows';

  @override
  String get pathsSubtitle =>
      'Explore user transitions across screens and events using Sankey journey diagrams.';

  @override
  String get pathsForward => 'Forward (From Start)';

  @override
  String get pathsReverse => 'Reverse (Leading to Target)';

  @override
  String get pathsRootEvent => 'Root Event / Screen';

  @override
  String get pathsRootPlaceholder => 'e.g. route:/login or error';

  @override
  String get pathsStepLimit => 'Step Depth';

  @override
  String get pathsExclude => 'Exclude Events';

  @override
  String get pathsExcludePlaceholder => 'e.g. heartbeat, pointer';

  @override
  String get pathsThreshold => 'Threshold (%)';

  @override
  String get pathsDiagramTitle => 'Transition Flow Diagram (Sankey)';

  @override
  String get pathsEmpty =>
      'No user paths found matching the selected criteria.';

  @override
  String pathsSampleSessions(int count) {
    return 'Sample Sessions ($count)';
  }

  @override
  String get pathsReplaysModalTitle => 'Journey Session Replays';

  @override
  String get pathsExit => 'Exit';

  @override
  String get navFeatureFlags => 'Feature Flags';

  @override
  String get flagsTitle => 'Feature Flags & Remote Config';

  @override
  String get flagsSubtitle =>
      'Toggle features instantly without deploying code, manage graduated rollouts and target user segments.';

  @override
  String get flagsNew => 'New Feature Flag';

  @override
  String get flagsKey => 'Flag Key';

  @override
  String get flagsKeyHint => 'e.g. new_checkout_flow';

  @override
  String get flagsName => 'Name';

  @override
  String get flagsDesc => 'Description';

  @override
  String get flagsRollout => 'Rollout Percentage (%)';

  @override
  String get flagsActive => 'Active';

  @override
  String get flagsDisabled => 'Disabled';

  @override
  String get flagsVariants => 'Variants';

  @override
  String get flagsFilters => 'Targeting Rules';

  @override
  String get flagsAddFilter => 'Add Rule';

  @override
  String get flagsAddVariant => 'Add Variant';

  @override
  String get flagsTestTitle => 'Live Evaluation Preview';

  @override
  String get flagsTestDistinctId => 'Distinct User ID';

  @override
  String get flagsTestResult => 'Evaluation Result';

  @override
  String get flagsDeleted => 'Feature flag deleted.';

  @override
  String get flagsSaved => 'Feature flag saved.';

  @override
  String get flagsEmpty => 'No feature flags created yet.';

  @override
  String get navExperiments => 'Experiments';

  @override
  String get experimentsTitle => 'Experiments (A/B Testing)';

  @override
  String get experimentsDesc =>
      'Run controlled A/B tests to improve conversion and validate hypotheses with statistical significance.';

  @override
  String get experimentsNew => 'New Experiment';

  @override
  String get experimentsRunning => 'Running';

  @override
  String get experimentsDraft => 'Draft';

  @override
  String get experimentsConcluded => 'Concluded';

  @override
  String get experimentsTargetMetric => 'Primary Metric Event';

  @override
  String get experimentsFlagKey => 'Linked Feature Flag';

  @override
  String get experimentsSampleSize => 'Target Sample Size';

  @override
  String get experimentsSignificant => 'Statistically Significant';

  @override
  String get experimentsNeedsData => 'Needs More Data';

  @override
  String get experimentsDeclareWinner => 'Declare Winner';

  @override
  String get experimentsRolloutWinner => 'Roll Out Winner to 100%';

  @override
  String get experimentsWinnerDeclared =>
      'Winner declared and feature flag rolled out to 100%.';

  @override
  String get experimentsConversionRate => 'Conversion Rate';

  @override
  String get experimentsParticipants => 'Participants';

  @override
  String get experimentsConversions => 'Conversions';

  @override
  String get experimentsRelativeLift => 'Relative Lift';

  @override
  String get experimentsChanceToWin => 'Chance to Win';

  @override
  String get experimentsConfidenceInterval => '95% Confidence Interval';

  @override
  String get experimentsEmpty => 'No A/B experiments created yet.';

  @override
  String get experimentsDeleteConfirm =>
      'Are you sure you want to delete this experiment?';

  @override
  String get navSurveys => 'Surveys & Feedback';

  @override
  String get surveysTitle => 'In-App Surveys & User Feedback';

  @override
  String get surveysDesc =>
      'Collect NPS, CSAT, and open text feedback directly linked to user session replays.';

  @override
  String get surveysNew => 'New Survey';

  @override
  String get surveysType => 'Survey Type';

  @override
  String get surveysQuestion => 'Question';

  @override
  String get surveysResponses => 'Responses';

  @override
  String get surveysNpsScore => 'Net Promoter Score (NPS)';

  @override
  String get surveysCsatScore => 'Customer Satisfaction (CSAT)';

  @override
  String get surveysPromoters => 'Promoters (9-10)';

  @override
  String get surveysPassives => 'Passives (7-8)';

  @override
  String get surveysDetractors => 'Detractors (0-6)';

  @override
  String get surveysWatchReplay => 'Watch Replay';

  @override
  String get surveysNoReplay => 'No Replay';

  @override
  String get surveysEmpty => 'No surveys created yet.';

  @override
  String get surveysDeleteConfirm =>
      'Are you sure you want to delete this survey?';

  @override
  String get surveysDeleted => 'Survey deleted.';

  @override
  String get surveysSaved => 'Survey saved.';

  @override
  String get surveysScoreDistribution => 'Score Distribution';

  @override
  String get surveysIndividualResponses => 'Individual Responses';

  @override
  String get surveysActive => 'Active';

  @override
  String get surveysInactive => 'Inactive';

  @override
  String get navCrons => 'Crons & Heartbeats';

  @override
  String get cronsTitle => 'Cron Jobs & Heartbeat Monitoring';

  @override
  String get cronsDesc =>
      'Monitor background jobs, scheduled tasks, and worker heartbeats with instant alerts on missed deadlines.';

  @override
  String get cronsNew => 'New Cron Monitor';

  @override
  String get cronsSchedule => 'Schedule (Crontab)';

  @override
  String get cronsTimezone => 'Timezone';

  @override
  String get cronsGracePeriod => 'Grace Period (min)';

  @override
  String get cronsMaxRuntime => 'Max Runtime (min)';

  @override
  String get cronsNextExpected => 'Next Expected';

  @override
  String get cronsLastCheckin => 'Last Check-in';

  @override
  String get cronsStatusOk => 'Healthy';

  @override
  String get cronsStatusInProgress => 'In Progress';

  @override
  String get cronsStatusMissed => 'Missed';

  @override
  String get cronsStatusError => 'Failed';

  @override
  String get cronsTimeline24h => '24-Hour Status Timeline';

  @override
  String get cronsIntegrationSnippets => 'Integration Code Snippets';

  @override
  String get cronsHistory => 'Check-in History';

  @override
  String get cronsEmpty => 'No cron monitors created yet.';

  @override
  String get cronsDeleteConfirm =>
      'Are you sure you want to delete this cron monitor?';

  @override
  String get cronsDeleted => 'Cron monitor deleted.';

  @override
  String get cronsSaved => 'Cron monitor saved.';

  @override
  String get cronsSlug => 'Slug / Identifier';

  @override
  String get cronsName => 'Monitor Name';

  @override
  String get cronsDuration => 'Duration';

  @override
  String get cronsMessage => 'Message';

  @override
  String get cronsTotal => 'Total Monitors';

  @override
  String get navUptime => 'Uptime & Synthetics';

  @override
  String get uptimeTitle => 'Uptime & Synthetic Monitoring';

  @override
  String get uptimeDesc =>
      'Actively monitor endpoint availability, response latency, and SSL certificate expiration.';

  @override
  String get uptimeNew => 'New Monitor';

  @override
  String get uptimeEdit => 'Edit Monitor';

  @override
  String get uptimeEmpty => 'No uptime monitors created yet.';

  @override
  String get uptimeEmptyDesc =>
      'Create synthetic health checks for your APIs and web apps to catch downtime instantly.';

  @override
  String get uptimeTotal => 'Total Monitors';

  @override
  String get uptimeSLA => 'SLA Uptime';

  @override
  String get uptimeUp => 'Operational';

  @override
  String get uptimeDegraded => 'Degraded';

  @override
  String get uptimeDown => 'Down';

  @override
  String get uptimeCheckNow => 'Check Now';

  @override
  String get uptimeChecking => 'Checking...';

  @override
  String get uptimeCheckedSuccess => 'Check completed successfully.';

  @override
  String get uptimeCheckedFailed => 'Check failed.';

  @override
  String get uptimeDeleteConfirm =>
      'Are you sure you want to delete this uptime monitor?';

  @override
  String get uptimeDeleted => 'Monitor deleted.';

  @override
  String get uptimeSaved => 'Monitor saved.';

  @override
  String get uptimeName => 'Monitor Name';

  @override
  String get uptimeURL => 'Target URL';

  @override
  String get uptimeMethod => 'HTTP Method';

  @override
  String get uptimeInterval => 'Check Interval';

  @override
  String get uptimeTimeout => 'Timeout';

  @override
  String get uptimeExpectedStatus => 'Expected Status Code';

  @override
  String get uptimeSSLCheck => 'SSL/TLS Certificate Check';

  @override
  String get uptimeSSLIssuer => 'Certificate Issuer';

  @override
  String get uptimeSSLExpires => 'SSL Expiration';

  @override
  String get uptimeSSLValid => 'Valid';

  @override
  String get uptimeSSLExpired => 'Expired';

  @override
  String uptimeSSLDaysLeft(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days remaining',
      one: '1 day remaining',
    );
    return '$_temp0';
  }

  @override
  String get uptimeTimeline90d => '90-Day Availability History';

  @override
  String get uptimeResponseTime => 'Response Time';

  @override
  String get uptimeAvgResponseTime => 'Avg Response Time';

  @override
  String get uptimeRecentChecks => 'Recent Checks';

  @override
  String get uptimeStatusCode => 'Status Code';

  @override
  String get uptimeCheckedAt => 'Checked At';

  @override
  String get uptimeErrorMessage => 'Error Detail';

  @override
  String get uptimeStatus => 'Status';

  @override
  String get uptimeLastChecked => 'Last Checked';

  @override
  String get navAlerts => 'Metric Alerts';

  @override
  String get alertsTitle => 'Metric Alerts & Anomaly Detection';

  @override
  String get alertsSubtitle =>
      'Monitor metric thresholds, anomaly spikes, and incident states.';

  @override
  String get alertsTabRules => 'Rules';

  @override
  String get alertsTabIncidents => 'Incident History';

  @override
  String get alertsNewRule => 'New Rule';

  @override
  String get alertsEditRule => 'Edit Rule';

  @override
  String get alertsRuleName => 'Rule Name';

  @override
  String get alertsMetricType => 'Metric Type';

  @override
  String get alertsComparison => 'Comparison Operator';

  @override
  String get alertsCriticalThreshold => 'Critical Threshold';

  @override
  String get alertsWarningThreshold => 'Warning Threshold (Optional)';

  @override
  String get alertsWindowMinutes => 'Evaluation Window';

  @override
  String get alertsTargetFilter => 'Target Filter (e.g. route:/checkout)';

  @override
  String get alertsChannels => 'Notification Channels';

  @override
  String get alertsSaveRule => 'Save Rule';

  @override
  String get alertsRuleSaved => 'Rule saved successfully.';

  @override
  String get alertsDeleteConfirm =>
      'Are you sure you want to delete this metric alert rule?';

  @override
  String get alertsDeleted => 'Rule deleted.';

  @override
  String get alertsStatusFiring => 'Firing';

  @override
  String get alertsStatusWarning => 'Warning';

  @override
  String get alertsStatusOk => 'OK';

  @override
  String get alertsStatusResolved => 'Resolved';

  @override
  String get alertsPreviewChart =>
      'Historical Metric & Threshold Preview (Last 7 Days)';

  @override
  String get alertsPreviewSub =>
      'Visualize when the rule would have triggered based on historical data.';

  @override
  String get alertsEmptyRules => 'No metric rules defined yet.';

  @override
  String get alertsEmptyIncidents => 'No recorded incidents.';

  @override
  String get alertsPeakValue => 'Peak Value';

  @override
  String get alertsDuration => 'Duration';

  @override
  String get alertsTriggerNow => 'Test Now';

  @override
  String get alertsOperatorGt => 'Greater than (>)';

  @override
  String get alertsOperatorGte => 'Greater than or equal (>=)';

  @override
  String get alertsOperatorLt => 'Less than (<)';

  @override
  String get alertsOperatorSpike => 'Anomaly Spike (x Multiplier)';

  @override
  String get alertsMetricErrorCount => 'Error Count';

  @override
  String get alertsMetricErrorRate => 'Error Rate (%)';

  @override
  String get alertsMetricP95Duration => 'p95 Latency (ms)';

  @override
  String get alertsMetricCrashCount => 'Crash Count';

  @override
  String get navTraces => 'Distributed Traces';

  @override
  String get tracesTitle => 'Distributed Traces & Spans';

  @override
  String get tracesSubtitle =>
      'Trace end-to-end distributed requests across microservices, databases, and identify N+1 bottlenecks.';

  @override
  String get tracesEmpty => 'No traces found for the selected filters.';

  @override
  String get tracesFilterService => 'Service';

  @override
  String get tracesFilterMinDuration => 'Min Duration (ms)';

  @override
  String get tracesSearchPlaceholder => 'Search trace ID or root operation...';

  @override
  String get traceDetailTitle => 'Trace Detail';

  @override
  String get traceDetailSpanCount => 'Total Spans';

  @override
  String get traceDetailServiceCount => 'Total Services';

  @override
  String get traceDetailDuration => 'Total Duration';

  @override
  String get traceSuspectNPlus1 => 'Suspected N+1 Query Bottleneck Detected!';

  @override
  String get traceSpanDetails => 'Span Details';

  @override
  String get traceSqlStatement => 'SQL Statement';

  @override
  String get traceAttributes => 'Attributes & Tags';

  @override
  String get traceStatus => 'Status';

  @override
  String get traceRootSpan => 'Root Operation';

  @override
  String get traceTimestamp => 'Start Time';

  @override
  String get performanceViewTrace => 'View Trace';

  @override
  String get navProfiling => 'Profiling';

  @override
  String get profilingTitle => 'Continuous Profiling & Flame Graph';

  @override
  String get profilingSubtitle =>
      'Analyze production call stacks, CPU bottlenecks, and slowest functions with interactive flame graphs.';

  @override
  String get profilingEmpty =>
      'No CPU profiles found for the selected filters.';

  @override
  String get profilingTransaction => 'Transaction';

  @override
  String get profilingDuration => 'Total Duration';

  @override
  String get profilingCpuTime => 'CPU Time';

  @override
  String get profilingThread => 'Thread';

  @override
  String get profilingPlatform => 'Platform';

  @override
  String get profilingSamples => 'Samples';

  @override
  String get profilingFrames => 'Frames';

  @override
  String get profilingSlowFunctions => 'Slowest Functions';

  @override
  String get profilingFunctionName => 'Function Name';

  @override
  String get profilingSelfTime => 'Self Time';

  @override
  String get profilingTotalTime => 'Total Time';

  @override
  String get profilingCallCount => 'Call Count';

  @override
  String get profilingDetailTitle => 'Profile & Flame Graph Detail';

  @override
  String get profilingSearchFrame => 'Search function or file...';

  @override
  String get profilingInvertFlame => 'Invert Graph (Icicle)';

  @override
  String get profilingResetZoom => 'Reset Zoom';

  @override
  String get profilingSelectedFrame => 'Selected Frame Details';

  @override
  String get profilingViewProfile => 'View Profile';

  @override
  String get navDashboards => 'Dashboards';

  @override
  String get dashboardsTitle => 'Custom Dashboards';

  @override
  String get dashboardsSubtitle =>
      'Build customized team dashboards and visualize analytical insights.';

  @override
  String get dashboardCreate => 'New Dashboard';

  @override
  String get dashboardEdit => 'Edit Dashboard';

  @override
  String get dashboardDelete => 'Delete Dashboard';

  @override
  String get dashboardName => 'Dashboard Name';

  @override
  String get dashboardNameHint => 'e.g. Executive Overview';

  @override
  String get dashboardDescription => 'Description';

  @override
  String get dashboardDescriptionHint =>
      'Briefly describe dashboard purpose...';

  @override
  String get dashboardSetDefault => 'Set as Default';

  @override
  String get dashboardIsDefault => 'Default Dashboard';

  @override
  String get dashboardEmpty => 'No custom dashboards created yet.';

  @override
  String get dashboardTileAdd => 'Add Insight';

  @override
  String get dashboardAutoRefresh => 'Auto Refresh';

  @override
  String get dashboardRefreshOff => 'Off';

  @override
  String get dashboardDeleteConfirm =>
      'Are you sure you want to delete this dashboard?';

  @override
  String get dashboardInsightRemove => 'Remove Insight';

  @override
  String get dashboardLayoutSave => 'Save Layout';

  @override
  String get insightBuilderTitle => 'Insight Query Builder';

  @override
  String get insightBuilderSubtitle =>
      'Define events, filters, and breakdowns to visualize metrics on the fly.';

  @override
  String get insightName => 'Insight Name';

  @override
  String get insightNameHint => 'e.g. Daily Purchase Volume';

  @override
  String get insightChartType => 'Chart Type';

  @override
  String get chartTypeLine => 'Line';

  @override
  String get chartTypeBar => 'Bar';

  @override
  String get chartTypeArea => 'Area';

  @override
  String get chartTypeNumber => 'Number (KPI)';

  @override
  String get chartTypeDonut => 'Donut';

  @override
  String get chartTypeTable => 'Table';

  @override
  String get insightDateRange => 'Date Range';

  @override
  String get insightInterval => 'Interval';

  @override
  String get intervalHour => 'Hourly';

  @override
  String get intervalDay => 'Daily';

  @override
  String get intervalWeek => 'Weekly';

  @override
  String get intervalMonth => 'Monthly';

  @override
  String get insightEvents => 'Analytics Events';

  @override
  String get insightEventAdd => 'Add Event';

  @override
  String get insightEventName => 'Event Name';

  @override
  String get insightEventNameHint => 'e.g. purchase, click, pageview';

  @override
  String get insightMath => 'Aggregation (Math)';

  @override
  String get mathCount => 'Total Count';

  @override
  String get mathUniqueUsers => 'Unique Users';

  @override
  String get mathAvg => 'Average';

  @override
  String get mathSum => 'Sum';

  @override
  String get mathMin => 'Minimum';

  @override
  String get mathMax => 'Maximum';

  @override
  String get mathP90 => '90th Percentile';

  @override
  String get insightProperty => 'Property Key';

  @override
  String get insightPropertyHint => 'e.g. amount, duration_ms';

  @override
  String get insightBreakdown => 'Breakdown by';

  @override
  String get insightBreakdownNone => 'No Breakdown';

  @override
  String get insightBreakdownPlatform => 'Platform';

  @override
  String get insightBreakdownBrowser => 'Browser';

  @override
  String get insightBreakdownCustom => 'Custom Property...';

  @override
  String get insightRunQuery => 'Run Query';

  @override
  String get insightSave => 'Save Insight';

  @override
  String get insightPreview => 'Visualization Preview';

  @override
  String get insightEmptyResults => 'No data points found for this query.';

  @override
  String get insightCached => 'Cached (60s)';

  @override
  String get insightDelete => 'Delete Insight';

  @override
  String get insightDeleteConfirm =>
      'Are you sure you want to delete this insight?';

  @override
  String dashboardsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dashboards',
      one: '1 dashboard',
    );
    return '$_temp0';
  }
}
