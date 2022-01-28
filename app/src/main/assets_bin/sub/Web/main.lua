require "import"
import "android.webkit.WebSettings"
import "mods.muk"
import "com.luxts.network.Networks"

pageurl=...

local debug_time_create_n=os.clock()

function onCreate()
  layout={
    RelativeLayout;
    layout_height="-1";
    layout_width="-1";
    background=backgroundc;
    id="_root";
    {
      RelativeLayout;
      layout_height="-1";
      layout_width="-1";
      {
        LuaWebView;--主体
        layout_height="-1";
        layout_width="-1";
        id="web";
      };
      {
        LinearLayout;
        orientation="vertical";
        layout_width="-1";
        layout_height="-1";
        background=viewshaderc;
      };
      {
        LinearLayout;
        layout_height="-1";
        layout_width="-1";
        gravity="center";
        orientation="vertical";
        background=backgroundc;
        onClick=function()end;
        id="jzdh";
        {
          LinearLayout;
          id="spb";
          layout_height="48dp";
          layout_width="48dp";
        };
        {
          TextView;
          text="加载中…";
          textColor=textc;
          textSize="14sp";
          id="jztitle";
          gravity="center";
          layout_width="-2";
          layout_height="-2";
          Typeface=字体("product");
          paddingTop="8dp";
        };
      };
    };
    {
      LinearLayout;
      orientation="vertical";
      layout_width="-1";
      layout_height="-1";
      gravity="top|left";
      {
        CardView;
        layout_width="40dp";
        layout_height="40dp";
        radius="20dp";
        Elevation="0dp";
        background=barbackgroundc;
        layout_margin="16dp";
        {
          LinearLayout;
          layout_width="-1";
          layout_height="-1";
          background="#00ffffff";
          id="back";
          onClick=function()关闭页面()end;
          {
            ImageView;
            src=图标("close");
            layout_height="-1";
            layout_width="-1";
            padding="10dp";
            colorFilter=textc;
          };
        };
      };
    };
  };

  设置视图(layout)

  波纹({back},"圆自适应")

  图标注释(back,"返回")

  web.getSettings().setLoadWithOverviewMode(true);
  web.getSettings().setUseWideViewPort(true);
  local webSettings = web.getSettings();
  

  web.getSettings().setSupportZoom(true);
  web.getSettings().setBuiltInZoomControls(true);
  web.getSettings().setDisplayZoomControls(false);
  web.getSettings().setDefaultFontSize(12);
  web.getSettings().setLoadWithOverviewMode(true);
  web.getSettings().setAllowFileAccess(true);
  web.getSettings().setJavaScriptEnabled(true);
  web.getSettings().setCacheMode(WebSettings.LOAD_NO_CACHE);
  web.getSettings().setAppCacheEnabled(true);
  web.getSettings().setDomStorageEnabled(true);
  web.getSettings().setDatabaseEnabled(true);
  web.getSettings().setUseWideViewPort(true);

  web.loadUrl(pageurl)--加载网页

  全屏()

  function 删除view(hiddenView)
    if nil ~= hiddenView then
      local parent = hiddenView.getParent()
      parent.removeView(hiddenView)
    end
  end

  web.removeView(web.getChildAt(0))

  import "org.jsoup.*"

  function 加载动画(n)
    jztitle.Text=n
    控件可见(jzdh)
  end

  function 设置值(anm)
    import "android.graphics.Paint$Align"
    import "android.graphics.Paint$FontMetrics"
    local myLuaDrawable=LuaDrawable(function(mCanvas,mPaint,mDrawable)

      --获取控件宽和高的最小值
      local r=math.min(mDrawable.getBounds().right,mDrawable.getBounds().bottom)

      --画笔属性
      mPaint.setColor(转0x(primaryc))
      mPaint.setAntiAlias(true)
      mPaint.setStrokeWidth(r/8)
      mPaint.setStyle(Paint.Style.STROKE)
      --mPaint.setStrokeCap(Paint.Cap.ROUND)

      local mPaint2=Paint()
      mPaint2.setColor(转0x(primaryc))
      mPaint2.setAntiAlias(true)
      mPaint2.setStrokeWidth(r/2)
      mPaint2.setStyle(Paint.Style.FILL)
      mPaint2.setTextAlign(Paint.Align.CENTER)
      mPaint2.setTextSize(sp2px(14))

      --圆弧绘制坐标范围:左上坐标,右下坐标

      return function(mCanvas)
        local n=anm*360/100

        local fontMetrics = mPaint2.getFontMetrics();
        local top = fontMetrics.top;--为基线到字体上边框的距离,即上图中的top
        local bottom = fontMetrics.bottom;--为基线到字体下边框的距离,即上图中的bottom

        local baseLineY =r/2 - top/2 - bottom/2

        if anm==100 then
          mCanvas.drawText("完成",r/2,baseLineY,mPaint2);
         else
          mCanvas.drawText(tostring(anm),r/2,baseLineY,mPaint2);
        end

        mCanvas.drawArc(RectF(r/8/2,r/8/2,r-r/8/2,r-r/8/2),-90,n,false,mPaint)

        --mDrawable.invalidateSelf()
      end
    end)

    --绘制的Drawble设置成控件背景
    spb.background=myLuaDrawable
  end

  import "com.lua.*"

  web.setWebChromeClient(LuaWebChrome(LuaWebChrome.IWebChrine{
    onProgressChanged=function(view, newProgress)
      设置值(newProgress)
    end
  }));

  web.setWebViewClient{
    shouldOverrideUrlLoading=function(view,url)
      wurl=url
      --Url即将跳转
      if wurl=="about_blank" then
       else
      end
    end,
    onPageStarted=function(view,url,favicon)
      wurl=url
      加载动画("正在努力加载中…")
    end,
    onPageFinished=function(view,url)
      if web.getTitle() == "网页无法打开" or web.getTitle() ==  web.getUrl() or web.getTitle() == "" then
        print("连接不上服务器捏，可能服务器抽风了罢，请稍后重试")
        activity.finish()
        else
      wurl=url

      控件隐藏(jzdh)
      end
    end
  }

  listalpha=AlphaAnimation(0,1)
  listalpha.setDuration(256)
  controller=LayoutAnimationController(listalpha)
  controller.setDelay(0.4)
  controller.setOrder(LayoutAnimationController.ORDER_NORMAL)
  _root.setLayoutAnimation(controller)
  
  local debug_time_create=os.clock()-debug_time_create_n
  if mukactivity.getData("Setting_Activity_LoadTime")=="true" then
    print(debug_time_create)
  end
end

activity.getSupportActionBar().hide()

function onResume()
if(Networks.isVpnUsed())then
print("抓包贵物给👴爬")
activity.finish()
end
end


this.getWindow().addFlags(WindowManager.LayoutParams.FLAG_SECURE)