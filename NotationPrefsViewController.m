//
//  NotationPrefsViewController.m
//  Notation
//
//  Created by Zachary Schneirov on 4/1/06.
//  Copyright 2006 Zachary Schneirov. All rights reserved.
//

#import "GlobalPrefs.h"
#import "NotationPrefsViewController.h"
#import "NotationPrefs.h"
#import "NSString_NV.h"
#import "PassphrasePicker.h"
#import "PassphraseChanger.h"

@implementation FileKindListView 

- (BOOL)acceptsFirstResponder {
    
    if (storageFormatPopupButton)
		return ([storageFormatPopupButton selectedTag] != SingleDatabaseFormat);
	
    return YES;
}
@end

@implementation NotationPrefsViewController

- (NSView*)view {
    if (!view) {
		if (![NSBundle loadNibNamed:@"NotationPrefsView" owner:self])  {
			NSLog(@"Failed to load NotationPrefsView.nib");
			return nil;
		}
    }
    
    return view;
}

- (id)init {
    if ([super init]) {
		didAwakeFromNib = NO;
		notationPrefs = [[[GlobalPrefs defaultPrefs] notationPrefs] retain];
		
		disableEncryptionString = NSLocalizedString(@"Turn Off Note Encryption...",nil);
		enableEncryptionString = NSLocalizedString(@"Turn On Note Encryption...",nil);
	
		[[GlobalPrefs defaultPrefs] registerForSettingChange:@selector(setNotationPrefs:sender:) withTarget:self];
    }
    return self;
}
- (void)dealloc {
	[picker release];
	[changer release];
	[notationPrefs release];
	[postStorageFormatInvocation release];
	
	[super dealloc];
}

- (void)awakeFromNib {
    didAwakeFromNib = YES;
    
    [allowedExtensionsTable setDataSource:self];
    [allowedTypesTable setDataSource:self];
    [allowedExtensionsTable setDelegate:self];
    [allowedTypesTable setDelegate:self];
	
	if (floor(NSAppKitVersionNumber) <= NSAppKitVersionNumber10_3) { // not on 10.4
		//prevent HTML storage format on 10.3.x, as it is not in Foundation
		[storageFormatPopupButton removeItemAtIndex:4];
	}
     
    [self initializeControls];
}

- (BOOL)tableView:(NSTableView *)aTableView shouldEditTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
	return (notationPrefs && [notationPrefs notesStorageFormat]);
}
- (BOOL)tableView:(NSTableView *)aTableView shouldSelectRow:(NSInteger)rowIndex {
    return (notationPrefs && [notationPrefs notesStorageFormat]);
}

- (void)settingChangedForSelectorString:(NSString*)selectorString {
	
	
	if ([selectorString isEqualToString:SEL_STR(setNotationPrefs:sender:)]) {
		
		//force these objects to re-init with the new notationprefs
		[changer release]; changer = nil;
		[picker release]; picker = nil;
		
		[notationPrefs release];
		notationPrefs = [[[GlobalPrefs defaultPrefs] notationPrefs] retain];
		
		if (didAwakeFromNib)
			[self initializeControls];
	}
}

- (void)initializeControls {
    //set up outlets to reflect new settings
    if (notationPrefs) {
		
		[keyLengthField setIntValue:[notationPrefs keyLengthInBits]];
		[keyLengthStepper setIntValue:[notationPrefs keyLengthInBits]];
		[self setEncryptionControlsState:[notationPrefs doesEncryption]];
		[self setSeparateFileControlsState:[notationPrefs notesStorageFormat]];
		[self updateRemoveKeychainItemStatus];
		[confirmFileDeletionButton setState:[notationPrefs confirmFileDeletion]];
		
		[notationalAccountField setStringValue:[notationPrefs serverUserName]];
		if ([notationPrefs serverUserName] && [[notationPrefs serverUserName] length] > 0)
			[notationalPasswordField setStringValue:@"xxxxxxxxxxxxxxxxxxxxxxxxx"];
		
		[secureTextEntryButton setState:[notationPrefs secureTextEntry]];
		
		[allowedTypesTable reloadData];
		[allowedExtensionsTable reloadData];
    }
}

- (void)setEncryptionControlsState:(BOOL)encryptionState {
    [enableEncryptionButton setTitle:(encryptionState ? disableEncryptionString : enableEncryptionString)];
    [changePasswordButton setEnabled:encryptionState];
	[passwordSettingsMatrix setEnabled:encryptionState];
	
	[passwordSettingsMatrix setState:[notationPrefs storesPasswordInKeychain] atRow:0 column:0];
	[passwordSettingsMatrix setState:![notationPrefs storesPasswordInKeychain] atRow:1 column:0];
	
    [keyLengthField setEnabled:encryptionState];
    [keyLengthStepper setEnabled:encryptionState];
}

- (void)setSeparateFileControlsState:(BOOL)separateFileControlsState {
	[newExtensionButton setEnabled:separateFileControlsState];
	[removeExtensionButton setEnabled:separateFileControlsState];
	[newTypeButton setEnabled:separateFileControlsState];
	[removeTypeButton setEnabled:separateFileControlsState];
	
	[allowedTypesTable setEnabled:separateFileControlsState];
	[allowedExtensionsTable setEnabled:separateFileControlsState];
	
	[confirmFileDeletionButton setEnabled:separateFileControlsState];
	
	int targetItem = [storageFormatPopupButton indexOfItemWithTag:[notationPrefs notesStorageFormat]];
	if (targetItem > -1)
		[storageFormatPopupButton selectItemAtIndex:targetItem];
	
	[fileAttributesHelpText setTextColor: separateFileControlsState ? [NSColor controlTextColor] : [NSColor grayColor]];	
}

- (void)updateRemoveKeychainItemStatus {
	
	if (![removeFromKeychainButton isHidden]) {
		SecKeychainItemRef itemRef = [notationPrefs currentKeychainItem];
		
		[removeFromKeychainButton setEnabled:(itemRef != NULL)];
		
		if (itemRef)
			CFRelease(itemRef);
	}
}

- (void)tableView:(NSTableView *)aTableView setObjectValue:(id)anObject 
   forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {

	if (aTableView == allowedExtensionsTable) {
		if (![notationPrefs setExtension:anObject atIndex:(unsigned int)rowIndex])
			[self removedExtension:self];
	} else if (aTableView == allowedTypesTable) {
		if (![notationPrefs setType:anObject atIndex:(unsigned int)rowIndex])
			[self removedType:self];
	}
}


- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {

	if (aTableView == allowedExtensionsTable)
		return [notationPrefs pathExtensionAtIndex:rowIndex];
	else if (aTableView == allowedTypesTable)
		return [notationPrefs typeStringAtIndex:rowIndex];
	
	return 0;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView {
	if (aTableView == allowedExtensionsTable)
		return [notationPrefs pathExtensionsCount];
	else if (aTableView == allowedTypesTable)
		return [notationPrefs typeStringsCount];
	
	return 0;
}

- (IBAction)addedExtension:(id)sender {
    [notationPrefs addAllowedPathExtension:@""];
	[allowedExtensionsTable reloadData];
	
	[allowedExtensionsTable selectRow:[notationPrefs pathExtensionsCount]-1 byExtendingSelection:NO];
	[allowedExtensionsTable editColumn:0 row:[notationPrefs pathExtensionsCount]-1 withEvent:nil select:YES];
}

- (IBAction)addedType:(id)sender {
    [notationPrefs addAllowedType:@""];
	[allowedTypesTable reloadData];
	
	[allowedTypesTable selectRow:[notationPrefs typeStringsCount]-1 byExtendingSelection:NO];
	[allowedTypesTable editColumn:0 row:[notationPrefs typeStringsCount]-1 withEvent:nil select:YES];

}

- (IBAction)changedKeyLength:(id)sender {
    
    int bits = [keyLengthStepper intValue];
    [keyLengthField setIntValue:bits];
    [notationPrefs setKeyLengthInBits:bits];
}

- (IBAction)changedKeychainSettings:(id)sender {
	//matrix does not change until the next runloop iteration, apparently
	if (sender != self)
		[self performSelector:@selector(changedKeychainSettings:) withObject:self afterDelay:0.0];
	else
		[notationPrefs setStoresPasswordInKeychain:[[passwordSettingsMatrix cellAtRow:0 column:0] state]];
		
}

- (IBAction)changedFileDeletionWarningSettings:(id)sender {
    [notationPrefs setConfirmsFileDeletion:[confirmFileDeletionButton state]];
}

- (IBAction)removeFromKeychain:(id)sender {
	[notationPrefs removeKeychainData];

	[self updateRemoveKeychainItemStatus];
}

- (int)notesStorageFormatInProgress {
	return notesStorageFormatInProgress;
}

- (void)runQueuedStorageFormatChangeInvocation {
	[postStorageFormatInvocation performSelector:@selector(invoke) withObject:nil afterDelay:0.0];
	[postStorageFormatInvocation release];
	postStorageFormatInvocation = nil;
}

- (void)notesStorageFormatDidChange {
	notesStorageFormatInProgress = [notationPrefs notesStorageFormat];
	[self setSeparateFileControlsState:notesStorageFormatInProgress];
	
    [allowedExtensionsTable reloadData];
    [allowedTypesTable reloadData];
}

- (IBAction)changedFileStorageFormat:(id)sender {
    int storageTag = [storageFormatPopupButton selectedTag];
	
	if (storageTag != SingleDatabaseFormat && [notationPrefs doesEncryption]) {
		if (NSRunAlertPanel(NSLocalizedString(@"Encryption is currently on, but storing notes individually requires it to be off. Disable encryption?",nil),
							NSLocalizedString(@"Warning: Your notes will be written to disk in clear text.",nil), NSLocalizedString(@"Disable Encryption",nil), 
							NSLocalizedString(@"Cancel",nil), NULL) == NSAlertDefaultReturn) {
			
			//disable encryption
			[self disableEncryptionWithWarning:NO];
		} else {
			//cancelled
			[self notesStorageFormatDidChange];
			return;
		}
	}
	
	notesStorageFormatInProgress = storageTag;
	
	//if we're changing to a database format from a non-database-format, ask to trash existing files
    if ([notationPrefs shouldDisplaySheetForProposedFormat:notesStorageFormatInProgress]) {
		
		NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Individual files remain in the notes directory. Leave them alone or move them to the Trash?",nil) 
										 defaultButton:NSLocalizedString(@"Keep Files", @"button title for not discarding note files") 
									   alternateButton:NSLocalizedString(@"Cancel",nil) otherButton:NSLocalizedString(@"Move to Trash", @"button title for trashing notes")
							 informativeTextWithFormat:NSLocalizedString(@"When notes are stored in a single database individual files become redundant.",nil)];
		
		[alert beginSheetModalForWindow:[view window] modalDelegate:notationPrefs 
						 didEndSelector:@selector(noteFilesCleanupSheetDidEnd:returnCode:contextInfo:) contextInfo:self];
		//will ultimately call -notesStorageFormatDidChange
	} else {
		//just call setNotesStorageFormat straight-out
		[notationPrefs setNotesStorageFormat:notesStorageFormatInProgress];
		[self notesStorageFormatDidChange];
		
		//sheet ending will not do this for us--there is no sheet
		[self runQueuedStorageFormatChangeInvocation];
	}
}
- (IBAction)verifySyncAccount:(id)sender {
    [[view window] endEditingFor:notationalAccountField];
    [[view window] endEditingFor:notationalPasswordField];
	
    
}
- (IBAction)showWebOptions:(id)sender {
    if (![webOptionsWindow isVisible])
		[webOptionsWindow center];
    
    [webOptionsWindow makeKeyAndOrderFront:sender];
}

- (IBAction)changedSecureTextEntry:(id)sender {
	[notationPrefs setSecureTextEntry:[secureTextEntryButton state]];
}

- (IBAction)changePassphrase:(id)sender {
	
	NSAssert([notationPrefs doesEncryption], @"Encryption must be on before the password can be changed.");
	
	if (!changer) changer = [[PassphraseChanger alloc] initWithNotationPrefs:notationPrefs];
	[changer showAroundWindow:[view window]];
}

- (IBAction)createNotationalAccount:(id)sender {
    //go to web page URL
}

- (IBAction)removedExtension:(id)sender {
	int selectedRow = [allowedExtensionsTable selectedRow];
	if (selectedRow > -1)
		[notationPrefs removeAllowedPathExtensionAtIndex:selectedRow];
	
	[allowedExtensionsTable reloadData];
}

- (IBAction)removedType:(id)sender {
	int selectedRow = [allowedTypesTable selectedRow];
	if (selectedRow > -1)
		[notationPrefs removeAllowedTypeAtIndex:selectedRow];
	
	[allowedTypesTable reloadData];
}

- (void)passphrasePicker:(PassphrasePicker*)picker choseAPassphrase:(BOOL)success {
	
	[self setEncryptionControlsState:success];
	[notationPrefs setDoesEncryption:success];
	[self updateRemoveKeychainItemStatus];
}

- (void)encryptionFormatMismatchSheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo {
	if (returnCode == NSAlertDefaultReturn) {
		//switching to single DB
		int targetItem = [storageFormatPopupButton indexOfItemWithTag:SingleDatabaseFormat];
		if (targetItem > -1)
			[storageFormatPopupButton selectItemAtIndex:targetItem];
		
		[self performSelector:@selector(changedFileStorageFormat:) withObject:storageFormatPopupButton afterDelay:0.0];
		
		//need to show PW picker dialog after this ->
		
		//[picker showAroundWindow:[view window] resultDelegate:self];
		
		[postStorageFormatInvocation release];
		
		//so queue it up:
		NSWindow *myWindow = [view window];
		SEL selector = @selector(showAroundWindow:resultDelegate:);
		postStorageFormatInvocation = [NSInvocation invocationWithMethodSignature:[picker methodSignatureForSelector:selector]];
		[postStorageFormatInvocation setSelector:selector];
		[postStorageFormatInvocation setTarget:picker];
		[postStorageFormatInvocation setArgument:&myWindow atIndex:2];
		[postStorageFormatInvocation setArgument:&self atIndex:3];
		[postStorageFormatInvocation retainArguments];
		[postStorageFormatInvocation retain];
	}
}

- (void)enableEncryption {
	if (!picker) picker = [[PassphrasePicker alloc] initWithNotationPrefs:notationPrefs];
	
	int format = [notationPrefs notesStorageFormat];
	if (format == SingleDatabaseFormat) {
		
		[picker showAroundWindow:[view window] resultDelegate:self];
	} else {
		NSString *formatStrings[] = { NSLocalizedString(@"(WHAT??)",@"user shouldn't see this"), 
			NSLocalizedString(@"plain text",nil), NSLocalizedString(@"rich text",nil), NSLocalizedString(@"HTML",nil) };
		NSAlert *alert = [NSAlert alertWithMessageText:[NSString stringWithFormat:NSLocalizedString(@"Your notes are currently stored as %@ files on disk, but encryption requires a single database. Switch to a database format?",nil), formatStrings[format]]
										 defaultButton:NSLocalizedString(@"Use a single database file",nil) alternateButton:NSLocalizedString(@"Cancel",nil) otherButton:nil
							 informativeTextWithFormat:NSLocalizedString(@"Notational Velocity supports encryption only for notes stored in a database file.",nil)];
		
		[alert beginSheetModalForWindow:[view window] modalDelegate:self 
						 didEndSelector:@selector(encryptionFormatMismatchSheetDidEnd:returnCode:contextInfo:) contextInfo:NULL];
	}
}

- (void)disableEncryptionWarningSheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo {
	if (returnCode == NSAlertDefaultReturn) {
		[self _disableEncryption];
	}
}

- (void)_disableEncryption {
	[self setEncryptionControlsState:NO];
	[notationPrefs setDoesEncryption:NO];
	[self updateRemoveKeychainItemStatus];
	
	[picker release]; picker = nil;		
}

- (void)disableEncryptionWithWarning:(BOOL)warning {
	if ([notationPrefs doesEncryption]) {
		if (warning) {
			NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Disable note encryption now?",nil)
											 defaultButton:NSLocalizedString(@"Disable Encryption",@"button title for disabling note encryption") 
										   alternateButton:NSLocalizedString(@"Cancel",nil) otherButton:nil
								 informativeTextWithFormat:NSLocalizedString(@"Warning: Your notes will be written to disk in clear text.",nil)];
			
			[alert beginSheetModalForWindow:[view window] modalDelegate:self 
							 didEndSelector:@selector(disableEncryptionWarningSheetDidEnd:returnCode:contextInfo:) contextInfo:NULL];
			
		} else {
			[self _disableEncryption];
		}
		
	} else {
		NSLog(@"Not disabling encryption because it is already off.");
	}
}

- (IBAction)toggledEncryption:(id)sender {
	BOOL encryptionOn = ![notationPrefs doesEncryption];
	
	if (encryptionOn) {
		[self enableEncryption];
	} else {
		[self disableEncryptionWithWarning:YES];
	}
}

@end
