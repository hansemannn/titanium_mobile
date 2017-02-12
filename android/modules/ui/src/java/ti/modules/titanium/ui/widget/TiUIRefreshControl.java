/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2015 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */
package ti.modules.titanium.ui.widget;

import org.appcelerator.kroll.KrollDict;
import org.appcelerator.titanium.TiApplication;
import org.appcelerator.titanium.proxy.TiViewProxy;
import org.appcelerator.titanium.view.TiUIView;
import org.appcelerator.titanium.util.TiRHelper;
import org.appcelerator.titanium.util.TiRHelper.ResourceNotFoundException;
import org.appcelerator.titanium.TiC;
import org.appcelerator.titanium.util.TiConvert;
import ti.modules.titanium.ui.widget.listview.TiRefreshControl

import android.support.v4.widget.SwipeRefreshLayout.OnRefreshListener;
import android.view.LayoutInflater;
import android.util.Log;

public class TiUIRefreshControl extends TiUIView {
    private static final String TAG = "TiUIRefreshControl";
    private TiRefreshControl layout;
    private TiViewProxy view;
    
    public static final String PROPERTY_VIEW = "view";
    
	public TiUIRefreshControl(TiViewProxy proxy) {
        super(proxy);
        
        int layout_swipe_refresh = TiRHelper.getResource("layout.titanium_ui_refresh_control");
        
        LayoutInflater inflater = LayoutInflater.from(TiApplication.getInstance());
        layout = (TiRefreshControl) inflater.inflate(layout_swipe_refresh, null, false);
        
        layout.setOnRefreshListener(new OnRefreshListener() {
            @Override
            public void onRefresh() {
                if (proxy.hasListeners("refreshstart")) {
                    proxy.fireEvent("refreshstart", null);
                }
            }
        });
        
        setNativeView(layout);
	}

    @Override
    public void processProperties(KrollDict d) {
        if (d.containsKey(PROPERTY_VIEW)) {
            Object view = d.get(PROPERTY_VIEW);
            if (view != null && view instanceof TiViewProxy) {
                this.view = (TiViewProxy) view;
                this.layout.setNativeView(this.view.getOrCreateView().getNativeView());
                this.layout.addView(this.view.getOrCreateView().getOuterView());
                
                if (d.containsKey(TiC.PROPERTY_TINT_COLOR)) {
                    final int tintColor = TiConvert.toColor(d, TiC.PROPERTY_TINT_COLOR);
                    this.layout.setColorSchemeColors(tintColor);
                }
            }
        }
        super.processProperties(d);
    }
    
    public boolean isRefreshing() {
        return this.layout.isRefreshing();
    }
    
    public void setRefreshing(boolean refreshing) {
        this.layout.setRefreshing(refreshing);
    }
}
