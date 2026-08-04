///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

part of 'strings.g.dart';

// Path: <root>
typedef TranslationsEn = Translations; // ignore: unused_element
class Translations with BaseTranslations<AppLocale, Translations> {
	/// Returns the current translations of the given [context].
	///
	/// Usage:
	/// final t = Translations.of(context);
	static Translations of(BuildContext context) => InheritedLocaleData.of<AppLocale, Translations>(context).translations;

	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	Translations({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.en,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <en>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	dynamic operator[](String key) => $meta.getTranslation(key);

	late final Translations _root = this; // ignore: unused_field

	Translations $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => Translations(meta: meta ?? this.$meta);

	// Translations

	/// en: 'Welcome to Buzzing'
	String get welcomeUse => 'Welcome to Buzzing';

	/// en: 'Buzzing makes communication smoother'
	String get welcomeHint => 'Buzzing makes communication smoother';

	/// en: 'Phone'
	String get phoneNum => 'Phone';

	/// en: 'Please enter the phone number'
	String get plsInputPhone => 'Please enter the phone number';

	/// en: 'Password'
	String get pwd => 'Password';

	/// en: 'Please enter the password'
	String get plsInputPwd => 'Please enter the password';

	/// en: 'Forget the password'
	String get forgetPwd => 'Forget the password';

	/// en: 'New User Registration'
	String get newUserRegister => 'New User Registration';

	/// en: 'Log in'
	String get login => 'Log in';

	/// en: 'I have read and agree:'
	String get iReadAgree => 'I have read and agree:';

	/// en: '《Service Agreement》'
	String get serviceAgreement => '《Service Agreement》';

	/// en: '《Privacy Policy》'
	String get privacyPolicy => '《Privacy Policy》';

	/// en: 'Phone or password cannot be empty'
	String get phoneOrPwdIsEmpty => 'Phone or password cannot be empty';

	/// en: 'Incorrect phone or password'
	String get phoneOrPwdIsError => 'Incorrect phone or password';

	/// en: 'Sign up now'
	String get nowRegister => 'Sign up now';

	/// en: 'The verification code has been sent to the phone'
	String get verifyCodeSentToPhone => 'The verification code has been sent to the phone';

	/// en: 'Please enter verification code'
	String get plsInputCode => 'Please enter verification code';

	/// en: 'After'
	String get after => 'After';

	/// en: 'resend verification code'
	String get resendVerifyCode => 'resend verification code';

	/// en: 'send verification code'
	String get sendVerifyCode => 'send verification code';

	/// en: 'Please set password'
	String get plsSetupPwd => 'Please set password';

	/// en: 'The login password is used to log in to the Buzzing account'
	String get pwdExplanation => 'The login password is used to log in to the Buzzing account';

	/// en: '6-20 characters'
	String get pwdRule => '6-20 characters';

	/// en: 'Next step'
	String get nextStep => 'Next step';

	/// en: 'Please complete personal information'
	String get plsFullSelfInfo => 'Please complete personal information';

	/// en: 'Click to upload avatar'
	String get clickUpdateAvatar => 'Click to upload avatar';

	/// en: 'Your name'
	String get yourName => 'Your name';

	/// en: 'Please fill in your real name'
	String get plsWriteRealName => 'Please fill in your real name';

	/// en: 'Enter Buzzing'
	String get enterApp => 'Enter Buzzing';

	/// en: 'Chats'
	String get home => 'Chats';

	/// en: 'Contacts'
	String get contacts => 'Contacts';

	/// en: 'Me'
	String get mine => 'Me';

	/// en: 'Search'
	String get search => 'Search';

	/// en: 'Top'
	String get top => 'Top';

	/// en: 'Cancel top'
	String get cancelTop => 'Cancel top';

	/// en: 'Delete'
	String get remove => 'Delete';

	/// en: 'Mark read'
	String get markRead => 'Mark read';

	/// en: 'Album'
	String get album => 'Album';

	/// en: 'Camera'
	String get camera => 'Camera';

	/// en: 'Video Call'
	String get videoCall => 'Video Call';

	/// en: 'Picture'
	String get picture => 'Picture';

	/// en: 'Video'
	String get video => 'Video';

	/// en: 'Voice'
	String get voice => 'Voice';

	/// en: 'Location'
	String get location => 'Location';

	/// en: 'File'
	String get file => 'File';

	/// en: 'Contact Card'
	String get carte => 'Contact Card';

	/// en: 'Voice Input'
	String get voiceInput => 'Voice Input';

	/// en: 'Have read'
	String get haveRead => 'Have read';

	/// en: 'Unread'
	String get unread => 'Unread';

	/// en: 'Read detail'
	String get readDetailTitle => 'Read detail';

	/// en: 'Refresh'
	String get refresh => 'Refresh';

	/// en: 'Copy'
	String get copy => 'Copy';

	/// en: 'Delete'
	String get delete => 'Delete';

	/// en: 'Forward'
	String get forward => 'Forward';

	/// en: 'Quote'
	String get reply => 'Quote';

	/// en: 'Revoke'
	String get revoke => 'Revoke';

	/// en: 'Multiple choice'
	String get multiChoice => 'Multiple choice';

	/// en: 'Translate'
	String get translation => 'Translate';

	/// en: 'Download'
	String get download => 'Download';

	/// en: 'Chat settings'
	String get chatSetup => 'Chat settings';

	/// en: 'Find chat history'
	String get findChatHistory => 'Find chat history';

	/// en: 'Pinned contacts'
	String get topContacts => 'Pinned contacts';

	/// en: 'Message Do Not Disturb'
	String get notDisturb => 'Message Do Not Disturb';

	/// en: 'Enable Ring'
	String get enableRing => 'Enable Ring';

	/// en: 'Enable Vibration'
	String get enableVibration => 'Enable Vibration';

	/// en: 'Complaint'
	String get complaint => 'Complaint';

	/// en: 'Clear chat history'
	String get clearHistory => 'Clear chat history';

	/// en: 'Select by friend'
	String get selectByFriends => 'Select by friend';

	/// en: 'Select by structure'
	String get selectByGroup => 'Select by structure';

	/// en: 'Select by tag'
	String get selectByTag => 'Select by tag';

	/// en: 'Select by group'
	String get selectByGroupChat => 'Select by group';

	/// en: 'Draft'
	String get draftText => 'Draft';

	/// en: 'You'
	String get you => 'You';

	/// en: 'revoke a message'
	String get revokeMsg => 'revoke a message';

	/// en: 'Cancel'
	String get cancel => 'Cancel';

	/// en: 'Merge forwarding'
	String get mergeForward => 'Merge forwarding';

	/// en: 'Confirm to send to：'
	String get confirmSendTo => 'Confirm to send to：';

	/// en: 'Confirm to send this business card to this chat?'
	String get confirmSendCarte => 'Confirm to send this business card to this chat?';

	/// en: 'Send'
	String get send => 'Send';

	/// en: 'Chat record'
	String get chatRecord => 'Chat record';

	/// en: 'Voice call'
	String get callVoice => 'Voice call';

	/// en: 'Video call'
	String get callVideo => 'Video call';

	/// en: 'Waiting for the other party to answer…'
	String get waitingAcceptVoiceCall => 'Waiting for the other party to answer…';

	/// en: 'Invites you to a voice call…'
	String get beInvitedVoiceCall => 'Invites you to a voice call…';

	/// en: 'Waiting for the other party to accept the invitation'
	String get waitingAcceptVideoCall => 'Waiting for the other party to accept the invitation';

	/// en: 'Invites you to a video call…'
	String get beInvitedVideoCall => 'Invites you to a video call…';

	/// en: 'Connecting…'
	String get callConnecting => 'Connecting…';

	/// en: 'Go to voice call'
	String get convertVoice => 'Go to voice call';

	/// en: 'Switch camera'
	String get switchCamera => 'Switch camera';

	/// en: 'Hangup'
	String get hangup => 'Hangup';

	/// en: 'Mute mic'
	String get muteMic => 'Mute mic';

	/// en: 'Share screen'
	String get shareScreen => 'Share screen';

	/// en: 'Stop sharing'
	String get stopScreenShare => 'Stop sharing';

	/// en: 'Entire screen'
	String get shareEntireScreen => 'Entire screen';

	/// en: 'Share your entire desktop'
	String get shareEntireScreenDesc => 'Share your entire desktop';

	/// en: 'Application window'
	String get shareWindow => 'Application window';

	/// en: 'Share a specific application window'
	String get shareWindowDesc => 'Share a specific application window';

	/// en: 'Self'
	String get self => 'Self';

	/// en: 'Pickup'
	String get pickup => 'Pickup';

	/// en: 'Refuse'
	String get refuse => 'Refuse';

	/// en: 'Microphone is on'
	String get micOpen => 'Microphone is on';

	/// en: 'Speaker is on'
	String get speakerOpen => 'Speaker is on';

	/// en: 'Microphone is off'
	String get micClose => 'Microphone is off';

	/// en: 'Speaker is off'
	String get speakerClose => 'Speaker is off';

	/// en: 'New friend'
	String get newFriend => 'New friend';

	/// en: 'My friend'
	String get myFriend => 'My friend';

	/// en: 'My Group'
	String get myGroup => 'My Group';

	/// en: 'Frequent contacts'
	String get oftenContacts => 'Frequent contacts';

	/// en: 'Add'
	String get add => 'Add';

	/// en: 'Create and join group chats'
	String get createAndJoinGroup => 'Create and join group chats';

	/// en: 'Create group chat'
	String get createGroup => 'Create group chat';

	/// en: 'Create group chats and fully use Buzzing'
	String get createGroupDescribe => 'Create group chats and fully use Buzzing';

	/// en: 'Join group chat'
	String get joinGroup => 'Join group chat';

	/// en: 'Communicate and collaborate with members'
	String get joinGroupDescribe => 'Communicate and collaborate with members';

	/// en: 'Add friend'
	String get addFriend => 'Add friend';

	/// en: 'Add group'
	String get addGroup => 'Add group';

	/// en: 'Search and add by user ID number'
	String get searchDescribe => 'Search and add by user ID number';

	/// en: 'Scan'
	String get scan => 'Scan';

	/// en: 'Scan QR code'
	String get scanDescribe => 'Scan QR code';

	/// en: 'New friend request'
	String get newFriendApplication => 'New friend request';

	/// en: 'Accept'
	String get accept => 'Accept';

	/// en: 'Greet'
	String get greet => 'Greet';

	/// en: 'Added successfully'
	String get addSuccessfully => 'Added successfully';

	/// en: 'Added failed'
	String get addFailed => 'Added failed';

	/// en: 'Search friends'
	String get searchFriend => 'Search friends';

	/// en: 'My information'
	String get myInfo => 'My information';

	/// en: 'Settings'
	String get mySetting => 'Settings';

	/// en: 'New message notification'
	String get newsNotify => 'New message notification';

	/// en: 'Account Settings'
	String get accountSetup => 'Account Settings';

	/// en: 'About us'
	String get aboutUs => 'About us';

	/// en: 'Sign out'
	String get logout => 'Sign out';

	/// en: 'Copy successfully'
	String get copySuccessfully => 'Copy successfully';

	/// en: 'QR code'
	String get qrcode => 'QR code';

	/// en: 'Scan the QR code below to add me as a friend'
	String get qrcodeTips => 'Scan the QR code below to add me as a friend';

	/// en: 'Remark'
	String get remark => 'Remark';

	/// en: 'ID code'
	String get idCode => 'ID code';

	/// en: 'Recommend him to a friend'
	String get recommendToFriends => 'Recommend him to a friend';

	/// en: 'Add to blacklist'
	String get addBlacklist => 'Add to blacklist';

	/// en: 'Unfriend'
	String get relieveRelationship => 'Unfriend';

	/// en: 'Send a message'
	String get sendMessage => 'Send a message';

	/// en: 'Buzzing call'
	String get appCall => 'Buzzing call';

	/// en: 'Launch group'
	String get launchGroup => 'Launch group';

	/// en: 'My QR code'
	String get myQrcode => 'My QR code';

	/// en: 'Invite the other party to scan the QR code and add friends'
	String get inviteScan => 'Invite the other party to scan the QR code and add friends';

	/// en: 'Scan QR code'
	String get scanQrcodeCarte => 'Scan QR code';

	/// en: 'The user cannot be found'
	String get searchFriendNoResult => 'The user cannot be found';

	/// en: 'Search：'
	String get searchPrefix => 'Search：';

	/// en: 'Can'
	String get notAddSelf => 'Can';

	/// en: 'Friend verification'
	String get friendVerify => 'Friend verification';

	/// en: 'Send friend request'
	String get sendFriendRequest => 'Send friend request';

	/// en: 'Remarks name'
	String get remarkName => 'Remarks name';

	/// en: 'Sent successfully'
	String get sendSuccessfully => 'Sent successfully';

	/// en: 'Failed to send'
	String get sendFailed => 'Failed to send';

	/// en: 'Friend request'
	String get friendRequests => 'Friend request';

	/// en: 'Apply through friends'
	String get acceptFriendRequests => 'Apply through friends';

	/// en: 'Set notes'
	String get setupRemark => 'Set notes';

	/// en: 'Remarks cannot be empty'
	String get remarkNotEmpty => 'Remarks cannot be empty';

	/// en: 'Save'
	String get save => 'Save';

	/// en: 'Save successfully'
	String get saveSuccessfully => 'Save successfully';

	/// en: 'Failed to save'
	String get saveFailed => 'Failed to save';

	/// en: 'View'
	String get see => 'View';

	/// en: 'View all friend requests'
	String get seeAllFriendRequests => 'View all friend requests';

	/// en: 'Are you sure you want to delete friends?'
	String get areYouSureDelFriend => 'Are you sure you want to delete friends?';

	/// en: 'Are you sure to add your friends to the blacklist?'
	String get areYouSureAddBlacklist => 'Are you sure to add your friends to the blacklist?';

	/// en: 'Whether to clear the chat history?'
	String get areYouSureClearAllHistory => 'Whether to clear the chat history?';

	/// en: 'Sure'
	String get sure => 'Sure';

	/// en: 'Empty'
	String get clearAll => 'Empty';

	/// en: 'Chosen:%s people'
	String get selectedNum => 'Chosen:%s people';

	/// en: 'Confirm(%s/%s)'
	String get confirmNum => 'Confirm(%s/%s)';

	/// en: 'Take a group name to facilitate subsequent searches'
	String get createGroupNameHint => 'Take a group name to facilitate subsequent searches';

	/// en: 'Group member'
	String get groupMember => 'Group member';

	/// en: 'Complete creation'
	String get completeCreation => 'Complete creation';

	/// en: '%s person'
	String get xPerson => '%s person';

	/// en: 'Avatar'
	String get avatar => 'Avatar';

	/// en: 'Nickname'
	String get nickname => 'Nickname';

	/// en: 'QR code'
	String get qrcodeCarte => 'QR code';

	/// en: 'Set nickname'
	String get setupNickname => 'Set nickname';

	/// en: 'Group chat settings'
	String get groupSetup => 'Group chat settings';

	/// en: 'Group chat name'
	String get groupName => 'Group chat name';

	/// en: 'Group announcement'
	String get groupAnnouncement => 'Group announcement';

	/// en: 'Group owner transfer'
	String get groupPermissionTransfer => 'Group owner transfer';

	/// en: 'My nickname in the group'
	String get myNicknameInGroup => 'My nickname in the group';

	/// en: 'Group QR code'
	String get groupQrcode => 'Group QR code';

	/// en: 'Group ID'
	String get groupIDCode => 'Group ID';

	/// en: 'View chat history'
	String get seeChatHistory => 'View chat history';

	/// en: 'Chat on top'
	String get chatTop => 'Chat on top';

	/// en: 'Exit group chat'
	String get quitGroup => 'Exit group chat';

	/// en: 'Edit group chat name'
	String get modifyGroupName => 'Edit group chat name';

	/// en: 'After modifying the group chat name, other members will be notified in the group.'
	String get modifyGroupNameHint => 'After modifying the group chat name, other members will be notified in the group.';

	/// en: 'Finished'
	String get finished => 'Finished';

	/// en: 'Please edit the group announcement'
	String get plsEditGroupAnnouncement => 'Please edit the group announcement';

	/// en: 'Scan the QR code of the group to join the group immediately.'
	String get groupQrcodeTips => 'Scan the QR code of the group to join the group immediately.';

	/// en: 'Search for the group ID number and join the group immediately.'
	String get groupIDTips => 'Search for the group ID number and join the group immediately.';

	/// en: 'Copy group ID'
	String get copyGroupID => 'Copy group ID';

	/// en: 'After the nickname is modified, it will only be displayed in this group, and all members of the group can see it.'
	String get modifyGroupUserNicknameHint => 'After the nickname is modified, it will only be displayed in this group, and all members of the group can see it.';

	/// en: 'Are you sure you want to delete group members?'
	String get confirmDelMember => 'Are you sure you want to delete group members?';

	/// en: 'Confirm to transfer the owner to:%s？'
	String get confirmTransferGroupToUser => 'Confirm to transfer the owner to:%s？';

	/// en: 'After exiting the group chat, you will no longer receive this group chat information.'
	String get quitGroupHint => 'After exiting the group chat, you will no longer receive this group chat information.';

	/// en: 'You are the owner of the group. If you want to quit the group chat, please transfer the owner'
	String get quitGroupTransferPermissionHint => 'You are the owner of the group. If you want to quit the group chat, please transfer the owner';

	/// en: 'Search: Group'
	String get searchGroupHint => 'Search: Group';

	/// en: 'I created'
	String get iCreateGroup => 'I created';

	/// en: 'I joined'
	String get iJoinGroup => 'I joined';

	/// en: 'Scan code to join'
	String get scanQrcodeJoin => 'Scan code to join';

	/// en: 'Scan the QR code business card to join the group chat'
	String get scanQrCodeJoinHint => 'Scan the QR code business card to join the group chat';

	/// en: 'ID number join'
	String get idCodeJoin => 'ID number join';

	/// en: 'Ask the administrator or team member for the number'
	String get idCodeJoinHint => 'Ask the administrator or team member for the number';

	/// en: 'Are you sure you want to log out？'
	String get confirmLogout => 'Are you sure you want to log out？';

	/// en: 'Do not disturb mode'
	String get notDisturbModel => 'Do not disturb mode';

	/// en: 'Add my way'
	String get addMyMethod => 'Add my way';

	/// en: 'Address book blacklist'
	String get blacklist => 'Address book blacklist';

	/// en: 'You can add me in the following ways'
	String get addMyMethodHint => 'You can add me in the following ways';

	/// en: 'You will no longer receive any messages from blacklisted users.'
	String get blacklistHint => 'You will no longer receive any messages from blacklisted users.';

	/// en: 'Are you sure to remove from the blacklist?'
	String get removeBlacklistHint => 'Are you sure to remove from the blacklist?';

	/// en: 'Go to rate'
	String get goToRate => 'Go to rate';

	/// en: 'Check the new version'
	String get checkVersion => 'Check the new version';

	/// en: 'New feature introduction'
	String get newFuncIntroduction => 'New feature introduction';

	/// en: 'Service Agreement'
	String get appServiceAgreement => 'Service Agreement';

	/// en: 'Buzzing Privacy Policy'
	String get appPrivacyPolicy => 'Buzzing Privacy Policy';

	/// en: 'Copyright Information'
	String get copyrightInformation => 'Copyright Information';

	/// en: 'Are you sure to recommend to %s?'
	String get confirmRecommendFriend => 'Are you sure to recommend to %s?';

	/// en: 'Call'
	String get call => 'Call';

	/// en: 'All calls'
	String get allCall => 'All calls';

	/// en: 'Missed call'
	String get missedCall => 'Missed call';

	/// en: 'Incoming call'
	String get incomingCall => 'Incoming call';

	/// en: 'Outgoing call'
	String get outgoingCall => 'Outgoing call';

	/// en: 'Connect'
	String get connect => 'Connect';

	/// en: 'Peers'
	String get peers => 'Peers';

	/// en: 'No peers available'
	String get noPeers => 'No peers available';

	/// en: '%s invite you to a group video call'
	String get groupCallVideoInvite => '%s invite you to a group video call';

	/// en: '%s invite you to a group voice call'
	String get groupCallVoiceInvite => '%s invite you to a group voice call';

	/// en: '%s people are in a video call'
	String get xPersonGroupVideoCalling => '%s people are in a video call';

	/// en: '%s people are in a voice call'
	String get xPersonGroupVoiceCalling => '%s people are in a voice call';

	/// en: 'Language settings'
	String get languageSetup => 'Language settings';

	/// en: 'Language'
	String get language => 'Language';

	/// en: 'English'
	String get english => 'English';

	/// en: 'Simple Chinese'
	String get chinese => 'Simple Chinese';

	/// en: 'Follow system'
	String get followSystem => 'Follow system';

	/// en: 'Typing...'
	String get typing => 'Typing...';

	/// en: 'Start download'
	String get startDownload => 'Start download';

	/// en: 'File has been saved'
	String get fileSaveToPath => 'File has been saved';

	/// en: 'Picture has been saved'
	String get picSaveToPath => 'Picture has been saved';

	/// en: 'Video has been saved'
	String get videoSaveToPath => 'Video has been saved';

	/// en: 'Call %s'
	String get callX => 'Call %s';

	/// en: 'Sent successfully'
	String get sentSuccessfully => 'Sent successfully';

	/// en: 'Only the owner can modify'
	String get onlyTheOwnerCanModify => 'Only the owner can modify';

	/// en: 'Please enter your phone number and password'
	String get plsInputPhoneAndPwd => 'Please enter your phone number and password';

	/// en: 'Please enter a valid phone number'
	String get plsInputRightPhone => 'Please enter a valid phone number';

	/// en: 'Please upload an avatar'
	String get plsUploadAvatar => 'Please upload an avatar';

	/// en: 'Name cannot be empty'
	String get nameNotEmpty => 'Name cannot be empty';

	/// en: 'Incorrect password format'
	String get pwdFormatError => 'Incorrect password format';

	/// en: 'Incorrect verification code'
	String get verifyCodeError => 'Incorrect verification code';

	/// en: 'Email'
	String get email => 'Email';

	/// en: 'Please enter the email'
	String get plsInputEmail => 'Please enter the email';

	/// en: 'Phone registration'
	String get phoneRegister => 'Phone registration';

	/// en: 'Email registration'
	String get emailRegister => 'Email registration';

	/// en: 'Please enter a valid email'
	String get plsInputRightEmail => 'Please enter a valid email';

	/// en: 'The verification code has been sent to the email'
	String get verifyCodeSentToEmail => 'The verification code has been sent to the email';

	/// en: 'Clear successfully'
	String get clearSuccess => 'Clear successfully';

	/// en: 'Google Maps'
	String get googleMap => 'Google Maps';

	/// en: 'Apple Maps'
	String get appleMap => 'Apple Maps';

	/// en: 'Baidu Maps'
	String get baiduMap => 'Baidu Maps';

	/// en: 'Amap Maps'
	String get amapMap => 'Amap Maps';

	/// en: 'Tencent Maps'
	String get tencentMap => 'Tencent Maps';

	/// en: 'New version found'
	String get upgradeFind => 'New version found';

	/// en: 'A new available version %s, your current version is %s'
	String get upgradeVersion => 'A new available version %s, your current version is %s';

	/// en: 'Release Notes:'
	String get upgradeDescription => 'Release Notes:';

	/// en: 'Ignore'
	String get upgradeIgnore => 'Ignore';

	/// en: 'Later'
	String get upgradeLater => 'Later';

	/// en: 'Immediately'
	String get upgradeNow => 'Immediately';

	/// en: '%s chat message'
	String get notificationChannelName => '%s chat message';

	/// en: 'Message from %s'
	String get notificationChannelDescription => 'Message from %s';

	/// en: 'You received a new message'
	String get notificationTitle => 'You received a new message';

	/// en: 'Message content:.....'
	String get notificationBody => 'Message content:.....';

	/// en: '%s background process'
	String get serviceChannelName => '%s background process';

	/// en: 'Ensure that the app can receive information'
	String get serviceChannelDescription => 'Ensure that the app can receive information';

	/// en: 'Running...'
	String get serviceNotificationBody => 'Running...';

	/// en: 'The group cannot be found'
	String get notFindGroup => 'The group cannot be found';

	/// en: 'Group ID number join'
	String get groupIdJoin => 'Group ID number join';

	/// en: 'Ask the administrator or group member for the number'
	String get groupIdJoinHint => 'Ask the administrator or group member for the number';

	/// en: 'ID number/Phone/Email/Nickname'
	String get searchUserDescribe => 'ID number/Phone/Email/Nickname';

	/// en: 'Search and add by group ID number'
	String get searchGroupDescribe => 'Search and add by group ID number';

	/// en: 'Apply to join the group'
	String get applyJoin => 'Apply to join the group';

	/// en: 'Enter group'
	String get enterGroup => 'Enter group';

	/// en: 'Enter group verification'
	String get enterGroupVerify => 'Enter group verification';

	/// en: 'Send enter group application'
	String get enterGroupHint => 'Send enter group application';

	/// en: 'Group application notice'
	String get groupApplicationNotification => 'Group application notice';

	/// en: 'Reason for application:'
	String get applyReason => 'Reason for application:';

	/// en: 'Approve'
	String get approve => 'Approve';

	/// en: 'Approved'
	String get approved => 'Approved';

	/// en: 'Rejected'
	String get rejected => 'Rejected';

	/// en: 'Approve group application'
	String get passGroupApplication => 'Approve group application';

	/// en: 'Reject group application'
	String get rejectGroupApplication => 'Reject group application';

	/// en: 'Choose default avatar'
	String get defaultAvatar => 'Choose default avatar';

	/// en: '~It'
	String get noMore => '~It';

	/// en: 'Online'
	String get online => 'Online';

	/// en: 'Offline'
	String get offline => 'Offline';

	/// en: 'Phone'
	String get phoneOnline => 'Phone';

	/// en: 'PC'
	String get pcOnline => 'PC';

	/// en: 'Web'
	String get webOnline => 'Web';

	/// en: 'MiniWeb'
	String get webMiniOnline => 'MiniWeb';

	/// en: 'Block friends'
	String get blockFriends => 'Block friends';

	/// en: 'Group message settings'
	String get groupMessageSettings => 'Group message settings';

	/// en: 'Friend message settings'
	String get friendMessageSettings => 'Friend message settings';

	/// en: 'Receive message but don'
	String get receiveMessageButNotPrompt => 'Receive message but don';

	/// en: 'Block group messages'
	String get blockGroupMessages => 'Block group messages';

	/// en: 'Warn!'
	String get accountWarn => 'Warn!';

	/// en: 'Your account has been logged in to another device, please change your password in time.'
	String get accountException => 'Your account has been logged in to another device, please change your password in time.';

	/// en: 'Invite members'
	String get inviteMember => 'Invite members';

	/// en: 'Remove members'
	String get removeMember => 'Remove members';

	/// en: 'Group owner'
	String get groupOwner => 'Group owner';

	/// en: 'Group admin'
	String get groupAdmin => 'Group admin';

	/// en: 'The announcement will notify all group members. Will it be released?'
	String get announcementHint => 'The announcement will notify all group members. Will it be released?';

	/// en: 'Publish'
	String get publish => 'Publish';

	/// en: 'More'
	String get more => 'More';

	/// en: 'I know'
	String get iKnow => 'I know';

	/// en: 'Discovery'
	String get workbench => 'Discovery';

	/// en: 'Call duration %s'
	String get callDuration => 'Call duration %s';

	/// en: 'Cancelled'
	String get cancelled => 'Cancelled';

	/// en: 'Cancelled by caller'
	String get cancelledByCaller => 'Cancelled by caller';

	/// en: 'Rejected by calle'
	String get rejectedByCaller => 'Rejected by calle';

	/// en: 'Time out'
	String get callTimeout => 'Time out';

	/// en: 'Unsupported Message'
	String get unsupportedMessage => 'Unsupported Message';

	/// en: 'Gender'
	String get gender => 'Gender';

	/// en: 'Birthday'
	String get birthday => 'Birthday';

	/// en: 'Man'
	String get man => 'Man';

	/// en: 'Woman'
	String get woman => 'Woman';

	/// en: 'Personal Information'
	String get personalInfo => 'Personal Information';

	/// en: 'Get verification code'
	String get getVerificationCode => 'Get verification code';

	/// en: 'Please set a new account password'
	String get setupNewPassword => 'Please set a new account password';

	/// en: 'Please enter a new password'
	String get plsInputNewPassword => 'Please enter a new password';

	/// en: 'Confirm the changes'
	String get confirmModify => 'Confirm the changes';

	/// en: 'Edit'
	String get edit => 'Edit';

	/// en: 'Favorite expressions'
	String get favoriteEmoticons => 'Favorite expressions';

	/// en: 'Manage'
	String get manageEmoticons => 'Manage';

	/// en: 'Completed'
	String get completed => 'Completed';

	/// en: 'Delete (%s)'
	String get deleteEmoticons => 'Delete (%s)';

	/// en: '%s in total'
	String get calEmoticonsNum => '%s in total';

	/// en: 'Burn after reading'
	String get burnAfterReading => 'Burn after reading';

	/// en: 'Set background'
	String get setChatBackground => 'Set background';

	/// en: 'Font size'
	String get fontSize => 'Font size';

	/// en: 'Little'
	String get little => 'Little';

	/// en: 'Standard'
	String get standard => 'Standard';

	/// en: 'Big'
	String get big => 'Big';

	/// en: 'Set Successfully'
	String get setSuccessfully => 'Set Successfully';

	/// en: 'Face'
	String get face => 'Face';

	/// en: 'Tag'
	String get tag => 'Tag';

	/// en: 'There are currently no tags'
	String get emptyTag => 'There are currently no tags';

	/// en: 'New tag'
	String get newTag => 'New tag';

	/// en: 'Tag name'
	String get tagName => 'Tag name';

	/// en: 'Tag member'
	String get tagMember => 'Tag member';

	/// en: 'Please enter a tag name'
	String get plsInputTagName => 'Please enter a tag name';

	/// en: 'Please select a tag member'
	String get plsSelectTagMember => 'Please select a tag member';

	/// en: 'Are you sure you want to delete this label?'
	String get confirmDeleteTag => 'Are you sure you want to delete this label?';

	/// en: 'Message read status'
	String get messageReadStatus => 'Message read status';

	/// en: 'Assign search content'
	String get assignSearchContent => 'Assign search content';

	/// en: 'No results found for %s'
	String get noFoundMessage => 'No results found for %s';

	/// en: 'This week'
	String get thisWeek => 'This week';

	/// en: 'This month'
	String get thisMonth => 'This month';

	/// en: 'Dismiss group'
	String get dismissGroup => 'Dismiss group';

	/// en: 'After disbanding the group chat, you will lose contact with the group members.'
	String get dismissGroupHint => 'After disbanding the group chat, you will lose contact with the group members.';

	/// en: 'All mute'
	String get mutedGroup => 'All mute';

	/// en: 'Set mute'
	String get setMute => 'Set mute';

	/// en: '10 minutes'
	String get tenMinutes => '10 minutes';

	/// en: '1 hour'
	String get oneHour => '1 hour';

	/// en: '12 hours'
	String get twelveHours => '12 hours';

	/// en: '1 day'
	String get oneDay => '1 day';

	/// en: 'Custom'
	String get custom => 'Custom';

	/// en: 'Day'
	String get day => 'Day';

	/// en: 'Work notification'
	String get workNotification => 'Work notification';

	/// en: 'Custom emoji'
	String get customEmoji => 'Custom emoji';

	/// en: '%s created a group chat'
	String get createGroupNotification => '%s created a group chat';

	/// en: '%s modified the group information'
	String get editGroupInfoNotification => '%s modified the group information';

	/// en: '%s left the group chat'
	String get quitGroupNotification => '%s left the group chat';

	/// en: '%s invited %s to the group chat'
	String get invitedJoinGroupNotification => '%s invited %s to the group chat';

	/// en: '%s was kicked out of the group chat by %s'
	String get kickedGroupNotification => '%s was kicked out of the group chat by %s';

	/// en: '%s joined the group chat'
	String get joinGroupNotification => '%s joined the group chat';

	/// en: '%s disbanded the group'
	String get dismissGroupNotification => '%s disbanded the group';

	/// en: '%s transferred the group to %s'
	String get transferredGroupNotification => '%s transferred the group to %s';

	/// en: '%s was muted by %s %s'
	String get muteGroupMemberNotification => '%s was muted by %s %s';

	/// en: '%s was unmuted by %s'
	String get muteCancelGroupMemberNotification => '%s was unmuted by %s';

	/// en: '%s open group mute'
	String get muteGroupNotification => '%s open group mute';

	/// en: '%s close group mute'
	String get muteCancelGroupNotification => '%s close group mute';

	/// en: 'You are now friends and can start chatting'
	String get friendAddedNotification => 'You are now friends and can start chatting';

	/// en: 'Burn after reading is activated'
	String get openPrivateChatNotification => 'Burn after reading is activated';

	/// en: 'Closed and burn after reading'
	String get closePrivateChatNotification => 'Closed and burn after reading';

	/// en: '%s edited his group member profile'
	String get groupMemberInfoChangedNotification => '%s edited his group member profile';

	/// en: 'Clear chat history'
	String get clearChatHistory => 'Clear chat history';

	/// en: 'Organization'
	String get organization => 'Organization';

	/// en: 'Album'
	String get selectFromAlbum => 'Album';

	/// en: 'Recover'
	String get recover => 'Recover';

	/// en: 'Are you sure you want to clear all chat history?'
	String get confirmClearChatHistory => 'Are you sure you want to clear all chat history?';

	/// en: 'Reject friend request'
	String get rejectFriendRequest => 'Reject friend request';

	/// en: 'Rejected successfully'
	String get rejectSuccessfully => 'Rejected successfully';

	/// en: 'Rejected failed'
	String get rejectFailed => 'Rejected failed';

	/// en: 'One minutes'
	String get oneMinutes => 'One minutes';

	/// en: 'Hour'
	String get hour => 'Hour';

	/// en: 'Minutes'
	String get minute => 'Minutes';

	/// en: 's'
	String get seconds => 's';

	/// en: 'Scan code to log in'
	String get scanQrLogin => 'Scan code to log in';

	/// en: 'Desktop login confirmation'
	String get pcLoginConfirmation => 'Desktop login confirmation';

	/// en: 'Confirm'
	String get confirmLogin => 'Confirm';

	/// en: 'Cancel'
	String get cancelLogin => 'Cancel';

	/// en: 'Login successful'
	String get loginSuccessful => 'Login successful';

	/// en: 'Login failed'
	String get loginFailed => 'Login failed';

	/// en: 'All'
	String get searchAll => 'All';

	/// en: 'Contacts'
	String get searchContacts => 'Contacts';

	/// en: 'Group'
	String get searchGroup => 'Group';

	/// en: 'Chat history'
	String get searchChatHistory => 'Chat history';

	/// en: 'File'
	String get searchFile => 'File';

	/// en: 'See more'
	String get seeMore => 'See more';

	/// en: '%s related chat records'
	String get relatedChatHistory => '%s related chat records';

	/// en: 'Group nickname: %s'
	String get groupNicknameIs => 'Group nickname: %s';

	/// en: '%s joined the group chat'
	String get joinGroupTimeIs => '%s joined the group chat';

	/// en: 'No more search results'
	String get noSearchResult => 'No more search results';

	/// en: 'Organization information'
	String get organizationInformation => 'Organization information';

	/// en: 'Business/Organization'
	String get businessOrOrganization => 'Business/Organization';

	/// en: 'Department'
	String get department => 'Department';

	/// en: 'Position'
	String get position => 'Position';

	/// en: 'View news'
	String get viewNews => 'View news';

	/// en: 'More info'
	String get moreInfo => 'More info';

	/// en: 'Preview font size'
	String get previewFontSize => 'Preview font size';

	/// en: 'Reset'
	String get reset => 'Reset';

	/// en: 'Group nickname'
	String get groupNickname => 'Group nickname';

	/// en: 'Join time'
	String get joinGroupTime => 'Join time';

	/// en: 'Make admin'
	String get makeAdmin => 'Make admin';

	/// en: 'Contact/Friend'
	String get searchFriendLabel => 'Contact/Friend';

	/// en: 'Contact/Colleague'
	String get searchDeptMemberLabel => 'Contact/Colleague';

	/// en: 'Friends'
	String get friends => 'Friends';

	/// en: 'Colleague'
	String get colleague => 'Colleague';

	/// en: 'Group'
	String get group => 'Group';

	/// en: 'Process'
	String get toBeProcessed => 'Process';

	/// en: 'Everyone'
	String get everyone => 'Everyone';

	/// en: '%s invited you to %s'
	String get inviteYouCall => '%s invited you to %s';

	/// en: 'Reject'
	String get rejectCall => 'Reject';

	/// en: 'Accept'
	String get acceptCall => 'Accept';

	/// en: 'Group verification settings'
	String get joinGroupSet => 'Group verification settings';

	/// en: 'Allow anyone to join the group'
	String get allowAnyoneJoinGroup => 'Allow anyone to join the group';

	/// en: 'Group member invitations do not require verification'
	String get inviteNotVerification => 'Group member invitations do not require verification';

	/// en: 'Need verification'
	String get needVerification => 'Need verification';

	/// en: 'Create workgroup'
	String get createWorkGroup => 'Create workgroup';

	/// en: 'Group type'
	String get groupType => 'Group type';

	/// en: 'General group'
	String get generalGroup => 'General group';

	/// en: 'Work group'
	String get workGroup => 'Work group';

	/// en: 'Member permissions'
	String get groupMemberPermissions => 'Member permissions';

	/// en: 'Not view member profiles'
	String get notViewMemberProfiles => 'Not view member profiles';

	/// en: 'Not add member to friend'
	String get notAddMemberToFriend => 'Not add member to friend';

	/// en: 'Join the group'
	String get joinGroupMethod => 'Join the group';

	/// en: '%s invited'
	String get byInviteJoinGroup => '%s invited';

	/// en: 'Group ID'
	String get byIDJoinGroup => 'Group ID';

	/// en: 'Group Qrcode'
	String get byQrcodeJoinGroup => 'Group Qrcode';

	/// en: 'Only group owners and admins can edit'
	String get groupNoticePermissionTips => 'Only group owners and admins can edit';

	/// en: 'invite'
	String get invite => 'invite';

	/// en: 'join in'
	String get joinIn => 'join in';

	/// en: 'invitation Code'
	String get invitationCode => 'invitation Code';

	/// en: 'The modification is successful, please log in again!'
	String get modifyPwdSuccessfully => 'The modification is successful, please log in again!';

	/// en: 'Modify failed, please try again!'
	String get modifyPwdFailed => 'Modify failed, please try again!';

	/// en: 'Cannot be the same as the initial password!'
	String get notSameAndInitialPassword => 'Cannot be the same as the initial password!';

	/// en: 'Custom Card'
	String get customCard => 'Custom Card';

	/// en: 'Normal Card'
	String get normalCard => 'Normal Card';

	/// en: 'The switch is successful, and it will take effect after restarting the app!'
	String get switchSuccessfully => 'The switch is successful, and it will take effect after restarting the app!';

	/// en: 'Moments'
	String get workMoments => 'Moments';

	/// en: '%s new messages'
	String get momentsNewMessage => '%s new messages';

	/// en: 'Loading...'
	String get loading => 'Loading...';

	/// en: 'Message'
	String get message => 'Message';

	/// en: 'mentioned：'
	String get momentsAtUsers => 'mentioned：';

	/// en: 'Publish Graphics'
	String get publishGraphic => 'Publish Graphics';

	/// en: 'Publish Video'
	String get publishVideo => 'Publish Video';

	/// en: 'Who can view'
	String get whoCanView => 'Who can view';

	/// en: 'At who view'
	String get atWhoView => 'At who view';

	/// en: 'Public'
	String get momentsPublic => 'Public';

	/// en: 'Visible to all'
	String get momentsPublicSub => 'Visible to all';

	/// en: 'Private'
	String get momentsPrivate => 'Private';

	/// en: 'Only visible to you'
	String get momentsPrivateSub => 'Only visible to you';

	/// en: 'Part'
	String get momentsPart => 'Part';

	/// en: 'The selected person is visible'
	String get momentsPartSub => 'The selected person is visible';

	/// en: 'Blocked'
	String get momentsBlocked => 'Blocked';

	/// en: 'The selected person is not visible'
	String get momentsBlockedSub => 'The selected person is not visible';

	/// en: 'Selected from group'
	String get momentsSelectedFromGroup => 'Selected from group';

	/// en: 'Selected from address book'
	String get momentsSelectedFromAddressBook => 'Selected from address book';

	/// en: 'roll up'
	String get rollUp => 'roll up';

	/// en: 'full text'
	String get fullText => 'full text';

	/// en: 'comment'
	String get comment => 'comment';

	/// en: 'many people like it'
	String get manyPeopleLikeIt => 'many people like it';

	/// en: 'Are you sure you want to clear the message?'
	String get confirmClearMessage => 'Are you sure you want to clear the message?';

	/// en: 'like you'
	String get likeYou => 'like you';

	/// en: 'comment you:'
	String get commentYou => 'comment you:';

	/// en: 'mentioned you'
	String get mentionYou => 'mentioned you';

	/// en: 'Detail'
	String get detail => 'Detail';

	/// en: 'Note!'
	String get note => 'Note!';

	/// en: 'Moments has gone!...'
	String get momentsGone => 'Moments has gone!...';

	/// en: 'moments empty！...'
	String get momentsEmpty => 'moments empty！...';

	/// en: 'camera permission be refuse, to open it ...'
	String get noCameraPermission => 'camera permission be refuse, to open it ...';

	/// en: 'Currently only supports forwarding up to twenty messages~'
	String get forwardMaxCountTips => 'Currently only supports forwarding up to twenty messages~';

	/// en: 'No internet.'
	String get noInternet => 'No internet.';

	/// en: 'connecting...'
	String get connecting => 'connecting...';

	/// en: 'Connection failed...'
	String get connectingFailed => 'Connection failed...';

	/// en: 'synchronizing...'
	String get synchronizing => 'synchronizing...';

	/// en: 'Sync failed...'
	String get syncFailed => 'Sync failed...';

	/// en: 'Group chat supports a maximum of %s people. If there are '
	String get tooManyPeopleTipsWhenCreateGroup => 'Group chat supports a maximum of %s people. If there are ';

	/// en: 'Just Now'
	String get justNow => 'Just Now';

	/// en: '%s people are on a audio call'
	String get groupAudioCallHint => '%s people are on a audio call';

	/// en: '%s people are on a video call'
	String get groupVideoCallHint => '%s people are on a video call';

	/// en: 'You are already on a call and cannot perform this operation!'
	String get callingBusy => 'You are already on a call and cannot perform this operation!';

	/// en: 'The current group is on a call, are you sure you want to join the current call?'
	String get groupCallForbidden => 'The current group is on a call, are you sure you want to join the current call?';

	/// en: 'Launch meeting'
	String get launchMeeting => 'Launch meeting';

	/// en: 'Join meeting'
	String get joinMeeting => 'Join meeting';

	/// en: 'Ready to join meeting'
	String get readyToJoin => 'Ready to join meeting';

	/// en: 'Microphone'
	String get microphoneDevice => 'Microphone';

	/// en: 'Camera'
	String get cameraDevice => 'Camera';

	/// en: 'Please enter a meeting subject'
	String get plsInputMeetingSubject => 'Please enter a meeting subject';

	/// en: 'Starting time'
	String get meetingStartTime => 'Starting time';

	/// en: 'Meeting duration'
	String get meetingDuration => 'Meeting duration';

	/// en: 'Enter the meeting'
	String get enterMeeting => 'Enter the meeting';

	/// en: 'Meeting number'
	String get meetingNo => 'Meeting number';

	/// en: 'Your name'
	String get yourMeetingName => 'Your name';

	/// en: 'Please enter the meeting number'
	String get plsInputMeetingNumber => 'Please enter the meeting number';

	/// en: 'Please enter your name'
	String get plsInputYouMeetingName => 'Please enter your name';

	/// en: 'Meeting topic: %s'
	String get meetingSubjectIs => 'Meeting topic: %s';

	/// en: 'Start time: %s'
	String get meetingStartTimeIs => 'Start time: %s';

	/// en: 'Meeting duration: %s'
	String get meetingDurationIs => 'Meeting duration: %s';

	/// en: 'Meeting ID: %s'
	String get meetingNumberIs => 'Meeting ID: %s';

	/// en: 'Click this message to join the meeting directly'
	String get meetingMessageClickHint => 'Click this message to join the meeting directly';

	/// en: 'Meeting news'
	String get meetingMessage => 'Meeting news';

	/// en: 'Open meeting'
	String get openMeeting => 'Open meeting';

	/// en: 'Did not start'
	String get didNotStart => 'Did not start';

	/// en: 'Started'
	String get started => 'Started';

	/// en: 'Meeting initiated by %s'
	String get meetingInitiator => 'Meeting initiated by %s';

	/// en: '请求参数错误'
	String get k10001 => '请求参数错误';

	/// en: '数据库错误'
	String get k10002 => '数据库错误';

	/// en: '服务器错误'
	String get k10003 => '服务器错误';

	/// en: '记录不存在'
	String get k10006 => '记录不存在';

	/// en: '账号已注册'
	String get k20001 => '账号已注册';

	/// en: '重复发送验证码'
	String get k20002 => '重复发送验证码';

	/// en: '邀请码错误'
	String get k20003 => '邀请码错误';

	/// en: '注册IP受限'
	String get k20004 => '注册IP受限';

	/// en: '验证码错误'
	String get k30001 => '验证码错误';

	/// en: '验证码已过期'
	String get k30002 => '验证码已过期';

	/// en: '邀请码被使用'
	String get k30003 => '邀请码被使用';

	/// en: '邀请码不存在'
	String get k30004 => '邀请码不存在';

	/// en: '账号未注册'
	String get k40001 => '账号未注册';

	/// en: '密码错误'
	String get k40002 => '密码错误';

	/// en: '登录受ip限制'
	String get k40003 => '登录受ip限制';

	/// en: 'ip禁止注册登录'
	String get k40004 => 'ip禁止注册登录';

	/// en: '过期'
	String get k50001 => '过期';

	/// en: '格式错误'
	String get k50002 => '格式错误';

	/// en: '未生效'
	String get k50003 => '未生效';

	/// en: '未知错误'
	String get k50004 => '未知错误';

	/// en: '创建错误'
	String get k50005 => '创建错误';

	/// en: 'Password login'
	String get usePwdLogin => 'Password login';

	/// en: 'SMS login'
	String get useSMSLogin => 'SMS login';

	/// en: 'Verification Code'
	String get verificationCode => 'Verification Code';

	/// en: 'please enter verification code'
	String get plsInputVerificationCode => 'please enter verification code';

	/// en: 'Unlock settings'
	String get unlockVerification => 'Unlock settings';

	/// en: 'Password'
	String get password => 'Password';

	/// en: 'Fingerprint'
	String get fingerprint => 'Fingerprint';

	/// en: 'Gesture'
	String get gesture => 'Gesture';

	/// en: 'Biometrics'
	String get biometrics => 'Biometrics';

	/// en: 'Please enter new passcode'
	String get plsEnterNewPwd => 'Please enter new passcode';

	/// en: 'Please enter passcode'
	String get plsEnterPwd => 'Please enter passcode';

	/// en: 'Please confirm new passcode'
	String get plsConfirmNewPwd => 'Please confirm new passcode';

	/// en: 'Reset input'
	String get resetInput => 'Reset input';

	/// en: 'Forbid add me as a friend'
	String get forbidAddMeToFriend => 'Forbid add me as a friend';

	/// en: 'After enabling, do not receive offline push messages'
	String get doNotDisturbHint => 'After enabling, do not receive offline push messages';

	/// en: '%s errors.'
	String get lockPwdErrorHint => '%s errors.';

	/// en: 'The user has been set and cannot be added!'
	String get notAddFriendHint => 'The user has been set and cannot be added!';

	/// en: 'Inconsistent drawing, please redraw!'
	String get gesturePwdConfirmErrorHint => 'Inconsistent drawing, please redraw!';

	/// en: '%s has enabled friend verification. You are not his or her friend. Please send a friend verification request first, and the other party can only chat after the verification is passed.'
	String get deletedByFriendHint => '%s has enabled friend verification. You are not his or her friend. Please send a friend verification request first, and the other party can only chat after the verification is passed.';

	/// en: 'Has been blocked'
	String get blockedByFriendHint => 'Has been blocked';

	/// en: 'Send friend verification'
	String get sendFriendVerification => 'Send friend verification';

	/// en: '(optional)'
	String get optional => '(optional)';

	/// en: 'Invitation code cannot be empty'
	String get invitationCodeNotEmpty => 'Invitation code cannot be empty';

	/// en: 'Please enter the invitation code'
	String get plsInputInvitationCode => 'Please enter the invitation code';

	/// en: 'Go Back'
	String get goBack => 'Go Back';

	/// en: 'Create Meeting'
	String get createMeeting => 'Create Meeting';

	/// en: 'Ok'
	String get ok => 'Ok';

	/// en: 'Internal Contacts'
	String get internalContacts => 'Internal Contacts';

	/// en: 'External Contacts'
	String get externalContacts => 'External Contacts';

	/// en: 'Star Contacts'
	String get starContacts => 'Star Contacts';

	/// en: 'Calendar'
	String get calendar => 'Calendar';

	/// en: 'Today'
	String get today => 'Today';

	/// en: 'Week'
	String get week => 'Week';

	/// en: 'Month'
	String get month => 'Month';

	/// en: 'New Schedule'
	String get newSchedule => 'New Schedule';

	/// en: 'Schedule Meeting'
	String get scheduleMeeting => 'Schedule Meeting';

	/// en: 'Coming Meeting'
	String get comingMeeting => 'Coming Meeting';

	/// en: 'History Meeting'
	String get historyMeeting => 'History Meeting';

	/// en: 'Meeting'
	String get meeting => 'Meeting';

	/// en: 'Server Configuration'
	String get serverConfig => 'Server Configuration';

	/// en: 'Server Address'
	String get serverAddress => 'Server Address';

	/// en: 'Port'
	String get port => 'Port';

	/// en: 'Add Server'
	String get addServer => 'Add Server';

	/// en: 'Please enter the server address'
	String get plsInputServerAddress => 'Please enter the server address';

	/// en: 'Please enter the port'
	String get plsInputPort => 'Please enter the port';

	/// en: 'Search calendars...'
	String get searchCalendarHint => 'Search calendars...';

	/// en: 'Title'
	String get scheduleTitle => 'Title';

	/// en: 'Calendar'
	String get scheduleCalendar => 'Calendar';

	/// en: 'All day'
	String get allDay => 'All day';

	/// en: 'Start date'
	String get startDate => 'Start date';

	/// en: 'End date'
	String get endDate => 'End date';

	/// en: 'Start'
	String get startTime => 'Start';

	/// en: 'End'
	String get endTime => 'End';

	/// en: 'Repeat: '
	String get repeat => 'Repeat: ';

	/// en: 'End: '
	String get endLabel => 'End: ';

	/// en: 'Daily'
	String get daily => 'Daily';

	/// en: 'Weekly'
	String get weekly => 'Weekly';

	/// en: 'Monthly'
	String get monthly => 'Monthly';

	/// en: 'Yearly'
	String get yearly => 'Yearly';

	/// en: 'Never'
	String get never => 'Never';

	/// en: 'On date'
	String get onDate => 'On date';

	/// en: ' every '
	String get every => ' every ';

	/// en: ' times'
	String get times => ' times';

	/// en: 'day(s)'
	String get recurrenceUnitDay => 'day(s)';

	/// en: 'week(s)'
	String get recurrenceUnitWeek => 'week(s)';

	/// en: 'month(s)'
	String get recurrenceUnitMonth => 'month(s)';

	/// en: 'year(s)'
	String get recurrenceUnitYear => 'year(s)';

	/// en: 'Every '
	String get everyPrefix => 'Every ';

	/// en: 'Reminders: '
	String get reminders => 'Reminders: ';

	/// en: 'At time'
	String get atTime => 'At time';

	/// en: ' min'
	String get minUnit => ' min';

	/// en: ' hr'
	String get hrUnit => ' hr';

	/// en: ' day'
	String get dayUnit => ' day';

	/// en: '(No title)'
	String get noTitle => '(No title)';

	/// en: 'Delete schedule'
	String get deleteSchedule => 'Delete schedule';

	/// en: 'Are you sure you want to delete this schedule?'
	String get confirmDeleteSchedule => 'Are you sure you want to delete this schedule?';

	/// en: 'Schedule reminder'
	String get scheduleReminder => 'Schedule reminder';

	/// en: 'Repeating'
	String get repeating => 'Repeating';

	/// en: '+ New Calendar'
	String get newCalendar => '+ New Calendar';

	/// en: 'My Calendar'
	String get myCalendar => 'My Calendar';

	/// en: 'Subscribed Calendar'
	String get subscribedCalendar => 'Subscribed Calendar';

	/// en: 'No results found'
	String get noResults => 'No results found';

	/// en: 'Enable'
	String get enable => 'Enable';

	/// en: 'Disable'
	String get disable => 'Disable';

	/// en: 'Change Color'
	String get changeColor => 'Change Color';

	/// en: 'Toggle Public'
	String get togglePublic => 'Toggle Public';

	/// en: 'Search Calendar'
	String get searchCalendar => 'Search Calendar';

	/// en: 'Search by name...'
	String get searchByName => 'Search by name...';

	/// en: 'Subscribed'
	String get subscribed => 'Subscribed';

	/// en: 'Subscribe'
	String get subscribe => 'Subscribe';

	/// en: 'Choose Color'
	String get chooseColor => 'Choose Color';

	/// en: 'Create Calendar'
	String get createCalendar => 'Create Calendar';

	/// en: 'Edit Calendar'
	String get editCalendar => 'Edit Calendar';

	/// en: 'Color'
	String get colorPickerLabel => 'Color';

	/// en: 'Public'
	String get publicLabel => 'Public';

	/// en: 'Name'
	String get name => 'Name';

	/// en: 'This event'
	String get thisEvent => 'This event';

	/// en: 'All events'
	String get allEvents => 'All events';

	/// en: 'This and future events'
	String get futureEvents => 'This and future events';

	/// en: 'Change only this occurrence'
	String get changeOnlyThis => 'Change only this occurrence';

	/// en: 'Change all occurrences in the series'
	String get changeAll => 'Change all occurrences in the series';

	/// en: 'Change this and all future occurrences'
	String get changeFuture => 'Change this and all future occurrences';

	/// en: 'How would you like to apply changes?'
	String get howToApply => 'How would you like to apply changes?';

	/// en: 'Edit repeating schedule'
	String get editRepeatingSchedule => 'Edit repeating schedule';

	/// en: 'Delete repeating schedule'
	String get deleteRepeatingSchedule => 'Delete repeating schedule';

	/// en: 'Mon'
	String get weekdayMon => 'Mon';

	/// en: 'Tue'
	String get weekdayTue => 'Tue';

	/// en: 'Wed'
	String get weekdayWed => 'Wed';

	/// en: 'Thu'
	String get weekdayThu => 'Thu';

	/// en: 'Fri'
	String get weekdayFri => 'Fri';

	/// en: 'Sat'
	String get weekdaySat => 'Sat';

	/// en: 'Sun'
	String get weekdaySun => 'Sun';

	/// en: 'Description'
	String get description => 'Description';

	/// en: 'Close'
	String get close => 'Close';

	/// en: 'View'
	String get view => 'View';

	/// en: 'Edit Schedule'
	String get editSchedule => 'Edit Schedule';

	/// en: 'Create Schedule'
	String get createSchedule => 'Create Schedule';

	/// en: 'Office'
	String get office => 'Office';

	/// en: 'New Space'
	String get addSpace => 'New Space';

	/// en: 'New Space'
	String get newSpace => 'New Space';

	/// en: 'Space name'
	String get spaceNameHint => 'Space name';

	/// en: 'Confirm'
	String get confirm => 'Confirm';

	/// en: 'Delete'
	String get deleteConfirm => 'Delete';

	/// en: 'Delete space'
	String get deleteSpace => 'Delete space';

	/// en: 'New Document'
	String get newDoc => 'New Document';

	/// en: 'Document title'
	String get docTitle => 'Document title';

	/// en: 'No documents'
	String get emptyDocs => 'No documents';

	/// en: 'Delete document'
	String get deleteDoc => 'Delete document';

	/// en: 'No spaces yet'
	String get noSpaces => 'No spaces yet';

	/// en: 'Speaker'
	String get speakerView => 'Speaker';

	/// en: 'Grid'
	String get gridView => 'Grid';

	/// en: 'Meeting Chat'
	String get meetingChat => 'Meeting Chat';

	/// en: 'No messages yet'
	String get noMessages => 'No messages yet';

	/// en: 'Type a message...'
	String get chatPlaceholder => 'Type a message...';

	/// en: 'joined the meeting'
	String get joinedMeeting => 'joined the meeting';

	/// en: 'left the meeting'
	String get leftMeeting => 'left the meeting';

	/// en: 'Messages'
	String get searchMessages => 'Messages';

	/// en: 'Chats'
	String get searchChats => 'Chats';

	/// en: 'Users'
	String get searchUsers => 'Users';

	/// en: 'Files'
	String get searchFiles => 'Files';

	/// en: 'Search messages, chats, users...'
	String get searchPlaceholder => 'Search messages, chats, users...';

	/// en: 'Search History'
	String get searchHistory => 'Search History';

	/// en: 'No results found'
	String get searchNoResults => 'No results found';

	/// en: 'Search in this chat'
	String get searchInChat => 'Search in this chat';

	/// en: '{count} results'
	String get searchResultCount => '{count} results';

	/// en: 'Previous'
	String get searchPrevious => 'Previous';

	/// en: 'Next'
	String get searchNext => 'Next';

	/// en: 'Hold to record'
	String get holdToRecord => 'Hold to record';

	/// en: 'Release to send'
	String get releaseToSend => 'Release to send';

	/// en: 'Swipe up to cancel'
	String get swipeUpCancel => 'Swipe up to cancel';

	/// en: 'Transcribe'
	String get transcribe => 'Transcribe';

	/// en: 'Voice message'
	String get voiceMsg => 'Voice message';

	/// en: 'Search location'
	String get searchLocation => 'Search location';

	/// en: 'Send this location'
	String get sendLocation => 'Send this location';

	/// en: 'Schedule send'
	String get scheduleSend => 'Schedule send';

	/// en: 'Scheduled messages'
	String get scheduledMessages => 'Scheduled messages';

	/// en: 'Pending'
	String get pending => 'Pending';

	/// en: 'Sent'
	String get sent => 'Sent';

	/// en: 'Translate'
	String get translate => 'Translate';
}

/// The flat map containing all translations for locale <en>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on Translations {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'welcomeUse' => 'Welcome to Buzzing',
			'welcomeHint' => 'Buzzing makes communication smoother',
			'phoneNum' => 'Phone',
			'plsInputPhone' => 'Please enter the phone number',
			'pwd' => 'Password',
			'plsInputPwd' => 'Please enter the password',
			'forgetPwd' => 'Forget the password',
			'newUserRegister' => 'New User Registration',
			'login' => 'Log in',
			'iReadAgree' => 'I have read and agree:',
			'serviceAgreement' => '《Service Agreement》',
			'privacyPolicy' => '《Privacy Policy》',
			'phoneOrPwdIsEmpty' => 'Phone or password cannot be empty',
			'phoneOrPwdIsError' => 'Incorrect phone or password',
			'nowRegister' => 'Sign up now',
			'verifyCodeSentToPhone' => 'The verification code has been sent to the phone',
			'plsInputCode' => 'Please enter verification code',
			'after' => 'After',
			'resendVerifyCode' => 'resend verification code',
			'sendVerifyCode' => 'send verification code',
			'plsSetupPwd' => 'Please set password',
			'pwdExplanation' => 'The login password is used to log in to the Buzzing account',
			'pwdRule' => '6-20 characters',
			'nextStep' => 'Next step',
			'plsFullSelfInfo' => 'Please complete personal information',
			'clickUpdateAvatar' => 'Click to upload avatar',
			'yourName' => 'Your name',
			'plsWriteRealName' => 'Please fill in your real name',
			'enterApp' => 'Enter Buzzing',
			'home' => 'Chats',
			'contacts' => 'Contacts',
			'mine' => 'Me',
			'search' => 'Search',
			'top' => 'Top',
			'cancelTop' => 'Cancel top',
			'remove' => 'Delete',
			'markRead' => 'Mark read',
			'album' => 'Album',
			'camera' => 'Camera',
			'videoCall' => 'Video Call',
			'picture' => 'Picture',
			'video' => 'Video',
			'voice' => 'Voice',
			'location' => 'Location',
			'file' => 'File',
			'carte' => 'Contact Card',
			'voiceInput' => 'Voice Input',
			'haveRead' => 'Have read',
			'unread' => 'Unread',
			'readDetailTitle' => 'Read detail',
			'refresh' => 'Refresh',
			'copy' => 'Copy',
			'delete' => 'Delete',
			'forward' => 'Forward',
			'reply' => 'Quote',
			'revoke' => 'Revoke',
			'multiChoice' => 'Multiple choice',
			'translation' => 'Translate',
			'download' => 'Download',
			'chatSetup' => 'Chat settings',
			'findChatHistory' => 'Find chat history',
			'topContacts' => 'Pinned contacts',
			'notDisturb' => 'Message Do Not Disturb',
			'enableRing' => 'Enable Ring',
			'enableVibration' => 'Enable Vibration',
			'complaint' => 'Complaint',
			'clearHistory' => 'Clear chat history',
			'selectByFriends' => 'Select by friend',
			'selectByGroup' => 'Select by structure',
			'selectByTag' => 'Select by tag',
			'selectByGroupChat' => 'Select by group',
			'draftText' => 'Draft',
			'you' => 'You',
			'revokeMsg' => 'revoke a message',
			'cancel' => 'Cancel',
			'mergeForward' => 'Merge forwarding',
			'confirmSendTo' => 'Confirm to send to：',
			'confirmSendCarte' => 'Confirm to send this business card to this chat?',
			'send' => 'Send',
			'chatRecord' => 'Chat record',
			'callVoice' => 'Voice call',
			'callVideo' => 'Video call',
			'waitingAcceptVoiceCall' => 'Waiting for the other party to answer…',
			'beInvitedVoiceCall' => 'Invites you to a voice call…',
			'waitingAcceptVideoCall' => 'Waiting for the other party to accept the invitation',
			'beInvitedVideoCall' => 'Invites you to a video call…',
			'callConnecting' => 'Connecting…',
			'convertVoice' => 'Go to voice call',
			'switchCamera' => 'Switch camera',
			'hangup' => 'Hangup',
			'muteMic' => 'Mute mic',
			'shareScreen' => 'Share screen',
			'stopScreenShare' => 'Stop sharing',
			'shareEntireScreen' => 'Entire screen',
			'shareEntireScreenDesc' => 'Share your entire desktop',
			'shareWindow' => 'Application window',
			'shareWindowDesc' => 'Share a specific application window',
			'self' => 'Self',
			'pickup' => 'Pickup',
			'refuse' => 'Refuse',
			'micOpen' => 'Microphone is on',
			'speakerOpen' => 'Speaker is on',
			'micClose' => 'Microphone is off',
			'speakerClose' => 'Speaker is off',
			'newFriend' => 'New friend',
			'myFriend' => 'My friend',
			'myGroup' => 'My Group',
			'oftenContacts' => 'Frequent contacts',
			'add' => 'Add',
			'createAndJoinGroup' => 'Create and join group chats',
			'createGroup' => 'Create group chat',
			'createGroupDescribe' => 'Create group chats and fully use Buzzing',
			'joinGroup' => 'Join group chat',
			'joinGroupDescribe' => 'Communicate and collaborate with members',
			'addFriend' => 'Add friend',
			'addGroup' => 'Add group',
			'searchDescribe' => 'Search and add by user ID number',
			'scan' => 'Scan',
			'scanDescribe' => 'Scan QR code',
			'newFriendApplication' => 'New friend request',
			'accept' => 'Accept',
			'greet' => 'Greet',
			'addSuccessfully' => 'Added successfully',
			'addFailed' => 'Added failed',
			'searchFriend' => 'Search friends',
			'myInfo' => 'My information',
			'mySetting' => 'Settings',
			'newsNotify' => 'New message notification',
			'accountSetup' => 'Account Settings',
			'aboutUs' => 'About us',
			'logout' => 'Sign out',
			'copySuccessfully' => 'Copy successfully',
			'qrcode' => 'QR code',
			'qrcodeTips' => 'Scan the QR code below to add me as a friend',
			'remark' => 'Remark',
			'idCode' => 'ID code',
			'recommendToFriends' => 'Recommend him to a friend',
			'addBlacklist' => 'Add to blacklist',
			'relieveRelationship' => 'Unfriend',
			'sendMessage' => 'Send a message',
			'appCall' => 'Buzzing call',
			'launchGroup' => 'Launch group',
			'myQrcode' => 'My QR code',
			'inviteScan' => 'Invite the other party to scan the QR code and add friends',
			'scanQrcodeCarte' => 'Scan QR code',
			'searchFriendNoResult' => 'The user cannot be found',
			'searchPrefix' => 'Search：',
			'notAddSelf' => 'Can',
			'friendVerify' => 'Friend verification',
			'sendFriendRequest' => 'Send friend request',
			'remarkName' => 'Remarks name',
			'sendSuccessfully' => 'Sent successfully',
			'sendFailed' => 'Failed to send',
			'friendRequests' => 'Friend request',
			'acceptFriendRequests' => 'Apply through friends',
			'setupRemark' => 'Set notes',
			'remarkNotEmpty' => 'Remarks cannot be empty',
			'save' => 'Save',
			'saveSuccessfully' => 'Save successfully',
			'saveFailed' => 'Failed to save',
			'see' => 'View',
			'seeAllFriendRequests' => 'View all friend requests',
			'areYouSureDelFriend' => 'Are you sure you want to delete friends?',
			'areYouSureAddBlacklist' => 'Are you sure to add your friends to the blacklist?',
			'areYouSureClearAllHistory' => 'Whether to clear the chat history?',
			'sure' => 'Sure',
			'clearAll' => 'Empty',
			'selectedNum' => 'Chosen:%s people',
			'confirmNum' => 'Confirm(%s/%s)',
			'createGroupNameHint' => 'Take a group name to facilitate subsequent searches',
			'groupMember' => 'Group member',
			'completeCreation' => 'Complete creation',
			'xPerson' => '%s person',
			'avatar' => 'Avatar',
			'nickname' => 'Nickname',
			'qrcodeCarte' => 'QR code',
			'setupNickname' => 'Set nickname',
			'groupSetup' => 'Group chat settings',
			'groupName' => 'Group chat name',
			'groupAnnouncement' => 'Group announcement',
			'groupPermissionTransfer' => 'Group owner transfer',
			'myNicknameInGroup' => 'My nickname in the group',
			'groupQrcode' => 'Group QR code',
			'groupIDCode' => 'Group ID',
			'seeChatHistory' => 'View chat history',
			'chatTop' => 'Chat on top',
			'quitGroup' => 'Exit group chat',
			'modifyGroupName' => 'Edit group chat name',
			'modifyGroupNameHint' => 'After modifying the group chat name, other members will be notified in the group.',
			'finished' => 'Finished',
			'plsEditGroupAnnouncement' => 'Please edit the group announcement',
			'groupQrcodeTips' => 'Scan the QR code of the group to join the group immediately.',
			'groupIDTips' => 'Search for the group ID number and join the group immediately.',
			'copyGroupID' => 'Copy group ID',
			'modifyGroupUserNicknameHint' => 'After the nickname is modified, it will only be displayed in this group, and all members of the group can see it.',
			'confirmDelMember' => 'Are you sure you want to delete group members?',
			'confirmTransferGroupToUser' => 'Confirm to transfer the owner to:%s？',
			'quitGroupHint' => 'After exiting the group chat, you will no longer receive this group chat information.',
			'quitGroupTransferPermissionHint' => 'You are the owner of the group. If you want to quit the group chat, please transfer the owner',
			'searchGroupHint' => 'Search: Group',
			'iCreateGroup' => 'I created',
			'iJoinGroup' => 'I joined',
			'scanQrcodeJoin' => 'Scan code to join',
			'scanQrCodeJoinHint' => 'Scan the QR code business card to join the group chat',
			'idCodeJoin' => 'ID number join',
			'idCodeJoinHint' => 'Ask the administrator or team member for the number',
			'confirmLogout' => 'Are you sure you want to log out？',
			'notDisturbModel' => 'Do not disturb mode',
			'addMyMethod' => 'Add my way',
			'blacklist' => 'Address book blacklist',
			'addMyMethodHint' => 'You can add me in the following ways',
			'blacklistHint' => 'You will no longer receive any messages from blacklisted users.',
			'removeBlacklistHint' => 'Are you sure to remove from the blacklist?',
			'goToRate' => 'Go to rate',
			'checkVersion' => 'Check the new version',
			'newFuncIntroduction' => 'New feature introduction',
			'appServiceAgreement' => 'Service Agreement',
			'appPrivacyPolicy' => 'Buzzing Privacy Policy',
			'copyrightInformation' => 'Copyright Information',
			'confirmRecommendFriend' => 'Are you sure to recommend to %s?',
			'call' => 'Call',
			'allCall' => 'All calls',
			'missedCall' => 'Missed call',
			'incomingCall' => 'Incoming call',
			'outgoingCall' => 'Outgoing call',
			'connect' => 'Connect',
			'peers' => 'Peers',
			'noPeers' => 'No peers available',
			'groupCallVideoInvite' => '%s invite you to a group video call',
			'groupCallVoiceInvite' => '%s invite you to a group voice call',
			'xPersonGroupVideoCalling' => '%s people are in a video call',
			'xPersonGroupVoiceCalling' => '%s people are in a voice call',
			'languageSetup' => 'Language settings',
			'language' => 'Language',
			'english' => 'English',
			'chinese' => 'Simple Chinese',
			'followSystem' => 'Follow system',
			'typing' => 'Typing...',
			'startDownload' => 'Start download',
			'fileSaveToPath' => 'File has been saved',
			'picSaveToPath' => 'Picture has been saved',
			'videoSaveToPath' => 'Video has been saved',
			'callX' => 'Call %s',
			'sentSuccessfully' => 'Sent successfully',
			'onlyTheOwnerCanModify' => 'Only the owner can modify',
			'plsInputPhoneAndPwd' => 'Please enter your phone number and password',
			'plsInputRightPhone' => 'Please enter a valid phone number',
			'plsUploadAvatar' => 'Please upload an avatar',
			'nameNotEmpty' => 'Name cannot be empty',
			'pwdFormatError' => 'Incorrect password format',
			'verifyCodeError' => 'Incorrect verification code',
			'email' => 'Email',
			'plsInputEmail' => 'Please enter the email',
			'phoneRegister' => 'Phone registration',
			'emailRegister' => 'Email registration',
			'plsInputRightEmail' => 'Please enter a valid email',
			'verifyCodeSentToEmail' => 'The verification code has been sent to the email',
			'clearSuccess' => 'Clear successfully',
			'googleMap' => 'Google Maps',
			'appleMap' => 'Apple Maps',
			'baiduMap' => 'Baidu Maps',
			'amapMap' => 'Amap Maps',
			'tencentMap' => 'Tencent Maps',
			'upgradeFind' => 'New version found',
			'upgradeVersion' => 'A new available version %s, your current version is %s',
			'upgradeDescription' => 'Release Notes:',
			'upgradeIgnore' => 'Ignore',
			'upgradeLater' => 'Later',
			'upgradeNow' => 'Immediately',
			'notificationChannelName' => '%s chat message',
			'notificationChannelDescription' => 'Message from %s',
			'notificationTitle' => 'You received a new message',
			'notificationBody' => 'Message content:.....',
			'serviceChannelName' => '%s background process',
			'serviceChannelDescription' => 'Ensure that the app can receive information',
			'serviceNotificationBody' => 'Running...',
			'notFindGroup' => 'The group cannot be found',
			'groupIdJoin' => 'Group ID number join',
			'groupIdJoinHint' => 'Ask the administrator or group member for the number',
			'searchUserDescribe' => 'ID number/Phone/Email/Nickname',
			'searchGroupDescribe' => 'Search and add by group ID number',
			'applyJoin' => 'Apply to join the group',
			'enterGroup' => 'Enter group',
			'enterGroupVerify' => 'Enter group verification',
			'enterGroupHint' => 'Send enter group application',
			'groupApplicationNotification' => 'Group application notice',
			'applyReason' => 'Reason for application:',
			'approve' => 'Approve',
			'approved' => 'Approved',
			'rejected' => 'Rejected',
			'passGroupApplication' => 'Approve group application',
			'rejectGroupApplication' => 'Reject group application',
			'defaultAvatar' => 'Choose default avatar',
			'noMore' => '~It',
			'online' => 'Online',
			'offline' => 'Offline',
			'phoneOnline' => 'Phone',
			'pcOnline' => 'PC',
			'webOnline' => 'Web',
			'webMiniOnline' => 'MiniWeb',
			'blockFriends' => 'Block friends',
			'groupMessageSettings' => 'Group message settings',
			'friendMessageSettings' => 'Friend message settings',
			'receiveMessageButNotPrompt' => 'Receive message but don',
			'blockGroupMessages' => 'Block group messages',
			'accountWarn' => 'Warn!',
			'accountException' => 'Your account has been logged in to another device, please change your password in time.',
			'inviteMember' => 'Invite members',
			'removeMember' => 'Remove members',
			'groupOwner' => 'Group owner',
			'groupAdmin' => 'Group admin',
			'announcementHint' => 'The announcement will notify all group members. Will it be released?',
			'publish' => 'Publish',
			'more' => 'More',
			'iKnow' => 'I know',
			'workbench' => 'Discovery',
			'callDuration' => 'Call duration %s',
			'cancelled' => 'Cancelled',
			'cancelledByCaller' => 'Cancelled by caller',
			'rejectedByCaller' => 'Rejected by calle',
			'callTimeout' => 'Time out',
			'unsupportedMessage' => 'Unsupported Message',
			'gender' => 'Gender',
			'birthday' => 'Birthday',
			'man' => 'Man',
			'woman' => 'Woman',
			'personalInfo' => 'Personal Information',
			'getVerificationCode' => 'Get verification code',
			'setupNewPassword' => 'Please set a new account password',
			'plsInputNewPassword' => 'Please enter a new password',
			'confirmModify' => 'Confirm the changes',
			'edit' => 'Edit',
			'favoriteEmoticons' => 'Favorite expressions',
			'manageEmoticons' => 'Manage',
			'completed' => 'Completed',
			'deleteEmoticons' => 'Delete (%s)',
			'calEmoticonsNum' => '%s in total',
			'burnAfterReading' => 'Burn after reading',
			'setChatBackground' => 'Set background',
			'fontSize' => 'Font size',
			'little' => 'Little',
			'standard' => 'Standard',
			'big' => 'Big',
			'setSuccessfully' => 'Set Successfully',
			'face' => 'Face',
			'tag' => 'Tag',
			'emptyTag' => 'There are currently no tags',
			'newTag' => 'New tag',
			'tagName' => 'Tag name',
			'tagMember' => 'Tag member',
			'plsInputTagName' => 'Please enter a tag name',
			'plsSelectTagMember' => 'Please select a tag member',
			'confirmDeleteTag' => 'Are you sure you want to delete this label?',
			'messageReadStatus' => 'Message read status',
			'assignSearchContent' => 'Assign search content',
			'noFoundMessage' => 'No results found for %s',
			'thisWeek' => 'This week',
			'thisMonth' => 'This month',
			'dismissGroup' => 'Dismiss group',
			'dismissGroupHint' => 'After disbanding the group chat, you will lose contact with the group members.',
			'mutedGroup' => 'All mute',
			'setMute' => 'Set mute',
			'tenMinutes' => '10 minutes',
			'oneHour' => '1 hour',
			'twelveHours' => '12 hours',
			'oneDay' => '1 day',
			'custom' => 'Custom',
			'day' => 'Day',
			'workNotification' => 'Work notification',
			'customEmoji' => 'Custom emoji',
			'createGroupNotification' => '%s created a group chat',
			'editGroupInfoNotification' => '%s modified the group information',
			'quitGroupNotification' => '%s left the group chat',
			'invitedJoinGroupNotification' => '%s invited %s to the group chat',
			'kickedGroupNotification' => '%s was kicked out of the group chat by %s',
			'joinGroupNotification' => '%s joined the group chat',
			'dismissGroupNotification' => '%s disbanded the group',
			'transferredGroupNotification' => '%s transferred the group to %s',
			'muteGroupMemberNotification' => '%s was muted by %s %s',
			'muteCancelGroupMemberNotification' => '%s was unmuted by %s',
			'muteGroupNotification' => '%s open group mute',
			'muteCancelGroupNotification' => '%s close group mute',
			'friendAddedNotification' => 'You are now friends and can start chatting',
			'openPrivateChatNotification' => 'Burn after reading is activated',
			'closePrivateChatNotification' => 'Closed and burn after reading',
			'groupMemberInfoChangedNotification' => '%s edited his group member profile',
			'clearChatHistory' => 'Clear chat history',
			'organization' => 'Organization',
			'selectFromAlbum' => 'Album',
			'recover' => 'Recover',
			'confirmClearChatHistory' => 'Are you sure you want to clear all chat history?',
			'rejectFriendRequest' => 'Reject friend request',
			'rejectSuccessfully' => 'Rejected successfully',
			'rejectFailed' => 'Rejected failed',
			'oneMinutes' => 'One minutes',
			'hour' => 'Hour',
			'minute' => 'Minutes',
			'seconds' => 's',
			'scanQrLogin' => 'Scan code to log in',
			'pcLoginConfirmation' => 'Desktop login confirmation',
			'confirmLogin' => 'Confirm',
			'cancelLogin' => 'Cancel',
			'loginSuccessful' => 'Login successful',
			'loginFailed' => 'Login failed',
			'searchAll' => 'All',
			'searchContacts' => 'Contacts',
			'searchGroup' => 'Group',
			'searchChatHistory' => 'Chat history',
			'searchFile' => 'File',
			'seeMore' => 'See more',
			'relatedChatHistory' => '%s related chat records',
			'groupNicknameIs' => 'Group nickname: %s',
			'joinGroupTimeIs' => '%s joined the group chat',
			'noSearchResult' => 'No more search results',
			'organizationInformation' => 'Organization information',
			'businessOrOrganization' => 'Business/Organization',
			'department' => 'Department',
			'position' => 'Position',
			'viewNews' => 'View news',
			'moreInfo' => 'More info',
			'previewFontSize' => 'Preview font size',
			'reset' => 'Reset',
			'groupNickname' => 'Group nickname',
			'joinGroupTime' => 'Join time',
			'makeAdmin' => 'Make admin',
			'searchFriendLabel' => 'Contact/Friend',
			'searchDeptMemberLabel' => 'Contact/Colleague',
			'friends' => 'Friends',
			'colleague' => 'Colleague',
			'group' => 'Group',
			'toBeProcessed' => 'Process',
			'everyone' => 'Everyone',
			'inviteYouCall' => '%s invited you to %s',
			'rejectCall' => 'Reject',
			'acceptCall' => 'Accept',
			'joinGroupSet' => 'Group verification settings',
			'allowAnyoneJoinGroup' => 'Allow anyone to join the group',
			'inviteNotVerification' => 'Group member invitations do not require verification',
			'needVerification' => 'Need verification',
			'createWorkGroup' => 'Create workgroup',
			'groupType' => 'Group type',
			'generalGroup' => 'General group',
			'workGroup' => 'Work group',
			'groupMemberPermissions' => 'Member permissions',
			'notViewMemberProfiles' => 'Not view member profiles',
			'notAddMemberToFriend' => 'Not add member to friend',
			'joinGroupMethod' => 'Join the group',
			'byInviteJoinGroup' => '%s invited',
			'byIDJoinGroup' => 'Group ID',
			'byQrcodeJoinGroup' => 'Group Qrcode',
			'groupNoticePermissionTips' => 'Only group owners and admins can edit',
			'invite' => 'invite',
			'joinIn' => 'join in',
			'invitationCode' => 'invitation Code',
			'modifyPwdSuccessfully' => 'The modification is successful, please log in again!',
			'modifyPwdFailed' => 'Modify failed, please try again!',
			'notSameAndInitialPassword' => 'Cannot be the same as the initial password!',
			'customCard' => 'Custom Card',
			'normalCard' => 'Normal Card',
			'switchSuccessfully' => 'The switch is successful, and it will take effect after restarting the app!',
			'workMoments' => 'Moments',
			'momentsNewMessage' => '%s new messages',
			'loading' => 'Loading...',
			'message' => 'Message',
			'momentsAtUsers' => 'mentioned：',
			'publishGraphic' => 'Publish Graphics',
			'publishVideo' => 'Publish Video',
			'whoCanView' => 'Who can view',
			'atWhoView' => 'At who view',
			'momentsPublic' => 'Public',
			'momentsPublicSub' => 'Visible to all',
			'momentsPrivate' => 'Private',
			'momentsPrivateSub' => 'Only visible to you',
			'momentsPart' => 'Part',
			'momentsPartSub' => 'The selected person is visible',
			'momentsBlocked' => 'Blocked',
			'momentsBlockedSub' => 'The selected person is not visible',
			'momentsSelectedFromGroup' => 'Selected from group',
			'momentsSelectedFromAddressBook' => 'Selected from address book',
			'rollUp' => 'roll up',
			'fullText' => 'full text',
			'comment' => 'comment',
			'manyPeopleLikeIt' => 'many people like it',
			'confirmClearMessage' => 'Are you sure you want to clear the message?',
			'likeYou' => 'like you',
			'commentYou' => 'comment you:',
			'mentionYou' => 'mentioned you',
			'detail' => 'Detail',
			'note' => 'Note!',
			'momentsGone' => 'Moments has gone!...',
			'momentsEmpty' => 'moments empty！...',
			'noCameraPermission' => 'camera permission be refuse, to open it ...',
			'forwardMaxCountTips' => 'Currently only supports forwarding up to twenty messages~',
			'noInternet' => 'No internet.',
			'connecting' => 'connecting...',
			'connectingFailed' => 'Connection failed...',
			'synchronizing' => 'synchronizing...',
			'syncFailed' => 'Sync failed...',
			'tooManyPeopleTipsWhenCreateGroup' => 'Group chat supports a maximum of %s people. If there are ',
			'justNow' => 'Just Now',
			'groupAudioCallHint' => '%s people are on a audio call',
			'groupVideoCallHint' => '%s people are on a video call',
			'callingBusy' => 'You are already on a call and cannot perform this operation!',
			'groupCallForbidden' => 'The current group is on a call, are you sure you want to join the current call?',
			'launchMeeting' => 'Launch meeting',
			'joinMeeting' => 'Join meeting',
			'readyToJoin' => 'Ready to join meeting',
			'microphoneDevice' => 'Microphone',
			'cameraDevice' => 'Camera',
			'plsInputMeetingSubject' => 'Please enter a meeting subject',
			'meetingStartTime' => 'Starting time',
			'meetingDuration' => 'Meeting duration',
			_ => null,
		} ?? switch (path) {
			'enterMeeting' => 'Enter the meeting',
			'meetingNo' => 'Meeting number',
			'yourMeetingName' => 'Your name',
			'plsInputMeetingNumber' => 'Please enter the meeting number',
			'plsInputYouMeetingName' => 'Please enter your name',
			'meetingSubjectIs' => 'Meeting topic: %s',
			'meetingStartTimeIs' => 'Start time: %s',
			'meetingDurationIs' => 'Meeting duration: %s',
			'meetingNumberIs' => 'Meeting ID: %s',
			'meetingMessageClickHint' => 'Click this message to join the meeting directly',
			'meetingMessage' => 'Meeting news',
			'openMeeting' => 'Open meeting',
			'didNotStart' => 'Did not start',
			'started' => 'Started',
			'meetingInitiator' => 'Meeting initiated by %s',
			'k10001' => '请求参数错误',
			'k10002' => '数据库错误',
			'k10003' => '服务器错误',
			'k10006' => '记录不存在',
			'k20001' => '账号已注册',
			'k20002' => '重复发送验证码',
			'k20003' => '邀请码错误',
			'k20004' => '注册IP受限',
			'k30001' => '验证码错误',
			'k30002' => '验证码已过期',
			'k30003' => '邀请码被使用',
			'k30004' => '邀请码不存在',
			'k40001' => '账号未注册',
			'k40002' => '密码错误',
			'k40003' => '登录受ip限制',
			'k40004' => 'ip禁止注册登录',
			'k50001' => '过期',
			'k50002' => '格式错误',
			'k50003' => '未生效',
			'k50004' => '未知错误',
			'k50005' => '创建错误',
			'usePwdLogin' => 'Password login',
			'useSMSLogin' => 'SMS login',
			'verificationCode' => 'Verification Code',
			'plsInputVerificationCode' => 'please enter verification code',
			'unlockVerification' => 'Unlock settings',
			'password' => 'Password',
			'fingerprint' => 'Fingerprint',
			'gesture' => 'Gesture',
			'biometrics' => 'Biometrics',
			'plsEnterNewPwd' => 'Please enter new passcode',
			'plsEnterPwd' => 'Please enter passcode',
			'plsConfirmNewPwd' => 'Please confirm new passcode',
			'resetInput' => 'Reset input',
			'forbidAddMeToFriend' => 'Forbid add me as a friend',
			'doNotDisturbHint' => 'After enabling, do not receive offline push messages',
			'lockPwdErrorHint' => '%s errors.',
			'notAddFriendHint' => 'The user has been set and cannot be added!',
			'gesturePwdConfirmErrorHint' => 'Inconsistent drawing, please redraw!',
			'deletedByFriendHint' => '%s has enabled friend verification. You are not his or her friend. Please send a friend verification request first, and the other party can only chat after the verification is passed.',
			'blockedByFriendHint' => 'Has been blocked',
			'sendFriendVerification' => 'Send friend verification',
			'optional' => '(optional)',
			'invitationCodeNotEmpty' => 'Invitation code cannot be empty',
			'plsInputInvitationCode' => 'Please enter the invitation code',
			'goBack' => 'Go Back',
			'createMeeting' => 'Create Meeting',
			'ok' => 'Ok',
			'internalContacts' => 'Internal Contacts',
			'externalContacts' => 'External Contacts',
			'starContacts' => 'Star Contacts',
			'calendar' => 'Calendar',
			'today' => 'Today',
			'week' => 'Week',
			'month' => 'Month',
			'newSchedule' => 'New Schedule',
			'scheduleMeeting' => 'Schedule Meeting',
			'comingMeeting' => 'Coming Meeting',
			'historyMeeting' => 'History Meeting',
			'meeting' => 'Meeting',
			'serverConfig' => 'Server Configuration',
			'serverAddress' => 'Server Address',
			'port' => 'Port',
			'addServer' => 'Add Server',
			'plsInputServerAddress' => 'Please enter the server address',
			'plsInputPort' => 'Please enter the port',
			'searchCalendarHint' => 'Search calendars...',
			'scheduleTitle' => 'Title',
			'scheduleCalendar' => 'Calendar',
			'allDay' => 'All day',
			'startDate' => 'Start date',
			'endDate' => 'End date',
			'startTime' => 'Start',
			'endTime' => 'End',
			'repeat' => 'Repeat: ',
			'endLabel' => 'End: ',
			'daily' => 'Daily',
			'weekly' => 'Weekly',
			'monthly' => 'Monthly',
			'yearly' => 'Yearly',
			'never' => 'Never',
			'onDate' => 'On date',
			'every' => ' every ',
			'times' => ' times',
			'recurrenceUnitDay' => 'day(s)',
			'recurrenceUnitWeek' => 'week(s)',
			'recurrenceUnitMonth' => 'month(s)',
			'recurrenceUnitYear' => 'year(s)',
			'everyPrefix' => 'Every ',
			'reminders' => 'Reminders: ',
			'atTime' => 'At time',
			'minUnit' => ' min',
			'hrUnit' => ' hr',
			'dayUnit' => ' day',
			'noTitle' => '(No title)',
			'deleteSchedule' => 'Delete schedule',
			'confirmDeleteSchedule' => 'Are you sure you want to delete this schedule?',
			'scheduleReminder' => 'Schedule reminder',
			'repeating' => 'Repeating',
			'newCalendar' => '+ New Calendar',
			'myCalendar' => 'My Calendar',
			'subscribedCalendar' => 'Subscribed Calendar',
			'noResults' => 'No results found',
			'enable' => 'Enable',
			'disable' => 'Disable',
			'changeColor' => 'Change Color',
			'togglePublic' => 'Toggle Public',
			'searchCalendar' => 'Search Calendar',
			'searchByName' => 'Search by name...',
			'subscribed' => 'Subscribed',
			'subscribe' => 'Subscribe',
			'chooseColor' => 'Choose Color',
			'createCalendar' => 'Create Calendar',
			'editCalendar' => 'Edit Calendar',
			'colorPickerLabel' => 'Color',
			'publicLabel' => 'Public',
			'name' => 'Name',
			'thisEvent' => 'This event',
			'allEvents' => 'All events',
			'futureEvents' => 'This and future events',
			'changeOnlyThis' => 'Change only this occurrence',
			'changeAll' => 'Change all occurrences in the series',
			'changeFuture' => 'Change this and all future occurrences',
			'howToApply' => 'How would you like to apply changes?',
			'editRepeatingSchedule' => 'Edit repeating schedule',
			'deleteRepeatingSchedule' => 'Delete repeating schedule',
			'weekdayMon' => 'Mon',
			'weekdayTue' => 'Tue',
			'weekdayWed' => 'Wed',
			'weekdayThu' => 'Thu',
			'weekdayFri' => 'Fri',
			'weekdaySat' => 'Sat',
			'weekdaySun' => 'Sun',
			'description' => 'Description',
			'close' => 'Close',
			'view' => 'View',
			'editSchedule' => 'Edit Schedule',
			'createSchedule' => 'Create Schedule',
			'office' => 'Office',
			'addSpace' => 'New Space',
			'newSpace' => 'New Space',
			'spaceNameHint' => 'Space name',
			'confirm' => 'Confirm',
			'deleteConfirm' => 'Delete',
			'deleteSpace' => 'Delete space',
			'newDoc' => 'New Document',
			'docTitle' => 'Document title',
			'emptyDocs' => 'No documents',
			'deleteDoc' => 'Delete document',
			'noSpaces' => 'No spaces yet',
			'speakerView' => 'Speaker',
			'gridView' => 'Grid',
			'meetingChat' => 'Meeting Chat',
			'noMessages' => 'No messages yet',
			'chatPlaceholder' => 'Type a message...',
			'joinedMeeting' => 'joined the meeting',
			'leftMeeting' => 'left the meeting',
			'searchMessages' => 'Messages',
			'searchChats' => 'Chats',
			'searchUsers' => 'Users',
			'searchFiles' => 'Files',
			'searchPlaceholder' => 'Search messages, chats, users...',
			'searchHistory' => 'Search History',
			'searchNoResults' => 'No results found',
			'searchInChat' => 'Search in this chat',
			'searchResultCount' => '{count} results',
			'searchPrevious' => 'Previous',
			'searchNext' => 'Next',
			'holdToRecord' => 'Hold to record',
			'releaseToSend' => 'Release to send',
			'swipeUpCancel' => 'Swipe up to cancel',
			'transcribe' => 'Transcribe',
			'voiceMsg' => 'Voice message',
			'searchLocation' => 'Search location',
			'sendLocation' => 'Send this location',
			'scheduleSend' => 'Schedule send',
			'scheduledMessages' => 'Scheduled messages',
			'pending' => 'Pending',
			'sent' => 'Sent',
			'translate' => 'Translate',
			_ => null,
		};
	}
}
