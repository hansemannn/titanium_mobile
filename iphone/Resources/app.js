/**
 * This file is used to validate iOS test-cases. It is ran using the Xcode
 * project in titanium_mobile/iphone/iphone/Titanium.xcodeproj.
 *
 * Change the below code to fit your use-case. By default, it included a button
 * to trigger a log that is displayed in the Xcode console.
 */

const win = Ti.UI.createWindow({
	backgroundColor: '#fff'
});

const btn = Ti.UI.createButton({
	title: 'Trigger'
});

btn.addEventListener('click', () => {
	const win2 = Ti.UI.createWindow({ title: 'Settings', backgroundColor: 'white' });
    win2.rightNavButton = Ti.UI.createButton({ title: 'Done', style: Ti.UI.iOS.SystemButtonStyle.DONE });
	win2.add(Ti.UI.createListView({
        style: Ti.UI.iOS.ListViewStyle.INSET_GROUPED,
		sections: [ Ti.UI.createListSection({
			items: [ {
				properties: { title: 'Item 1' }
			}, {
				properties: { title: 'Item 2' }
			} ]
		}), Ti.UI.createListSection({
			items: [ {
				properties: { title: 'Item 1' }
			}, {
				properties: { title: 'Item 2' }
			} ]
		}) ]
	}));

	const nav = Ti.UI.createNavigationWindow({ window: win2 });
	nav.open({ modal: true, modalSizes: [ Ti.UI.iOS.MODAL_SIZE_MEDIUM ], modalStyle: Ti.UI.iOS.MODAL_PRESENTATION_FORMSHEET });
});

win.add(btn);
win.open();
