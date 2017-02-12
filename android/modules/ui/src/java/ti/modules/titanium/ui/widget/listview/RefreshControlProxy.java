/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2013 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

package ti.modules.titanium.ui.widget.listview;

import org.appcelerator.kroll.annotations.Kroll;
import org.appcelerator.kroll.KrollProxy;
import org.appcelerator.titanium.proxy.TiViewProxy;
import org.appcelerator.titanium.view.TiUIView;
import org.appcelerator.titanium.TiApplication;
import ti.modules.titanium.ui.widget.TiUIRefreshControl;

import android.app.Activity;
import android.os.Handler;
import android.os.Message;

@Kroll.proxy(creatableInModule = UIModule.class)
public class RefreshControlProxy extends TiViewProxy implements Handler.Callback {

	private TiUIRefreshControl swipeRefresh;

	protected static final int MSG_SET_REFRESHING = KrollProxy.MSG_LAST_ID + 101;

	public RefreshControlProxy() {
		super();
	}

	@Override
	public TiUIView createView(Activity activity) {
		swipeRefresh = new TiUIRefreshControl(this);
		return this.swipeRefresh;
	}
    
	/* Public API */
	

    @Kroll.method
    public void beginRefreshing() {
        if (TiApplication.isUIThread()) {
            doSetRefreshing(true);
        } else {
            Message message = getMainHandler().obtainMessage(MSG_SET_REFRESHING, true);
            message.sendToTarget();
        }
    }

    @Kroll.method
    public void endRefreshing() {
        if (TiApplication.isUIThread()) {
            doSetRefreshing(false);
        } else {
            Message message = getMainHandler().obtainMessage(MSG_SET_REFRESHING, false);
            message.sendToTarget();
        }
    }

	/* Utilities */
    
	public boolean handleMessage(Message message) {
		switch (message.what) {
			case MSG_SET_REFRESHING: {
				doSetRefreshing((Boolean) message.obj);
				return true;
			}
		}
		
		return super.handleMessage(message);
	}
	
	protected void doSetRefreshing(boolean refreshing) {
		this.swipeRefresh.setRefreshing(refreshing);
	}
}
