require "import"
--import "androidx"
import "androidx.appcompat.app.*"
import "androidx.appcompat.view.*"
import "androidx.appcompat.widget.*"
import "android.app.*"
import "android.os.*"
import "android.widget.*"
import "android.view.*"

import "mods.muk"
import "com.michael.NoScrollListView"
import "com.michael.NoScrollGridView"
import "com.luxts.network.Networks"

import "androidx.coordinatorlayout.widget.CoordinatorLayout"

activity.setContentView(loadlayout("layout"))

bwz=0x3f000000
primaryc="#F8D800"

listalpha=AlphaAnimation(0,1)
listalpha.setDuration(256)
controller=LayoutAnimationController(listalpha)
controller.setDelay(0.4)
controller.setOrder(LayoutAnimationController.ORDER_NORMAL)

swipe1.setProgressViewOffset(true,0, 64)
swipe1.setColorSchemeColors({转0x(primaryc),转0x(primaryc)-0x9f000000})
swipe1.setProgressBackgroundColorSchemeColor(转0x(barbackgroundc))
swipe1.setOnRefreshListener(SwipeRefreshLayout.OnRefreshListener{onRefresh=function()
    print("刷新中...")
    homeadp.clear()
    getHuos()
    homelist.setLayoutAnimation(controller)
    swipe1.setRefreshing(false)
end})

function getHuos()
Http.get("https://wds.ecsxs.com/220450.txt",nil,nil,nil,function(code,content,cookie,header)
if code==200 then
  pcall(load(content))
  else
  homeadp.add{__type=1,title={text="狠活博物馆"},content="请确认网络是否有问题，如果网络无问题请下拉刷新"}
  end
end)
end

function 颜色字体(t,c)
  local sp = SpannableString(t)
  sp.setSpan(ForegroundColorSpan(c),0,#sp,Spannable.SPAN_EXCLUSIVE_INCLUSIVE)
   return sp
end

activity.getSupportActionBar().setBackgroundDrawable(ColorDrawable(0xffffffff))
activity.setTitle(颜色字体("狠活博物馆",转0x(primaryc)))

homeitem={
  {
    LinearLayout;
    layout_width="-1";
    layout_height="-2";
    orientation="vertical";
    onClick=function()end;
    {
      CardView;
      CardElevation="0dp";
      CardBackgroundColor=cardbackc;
      Radius="8dp";
      layout_width="-1";
      layout_height="-2";
      layout_margin="16dp";
      layout_marginTop="8dp";
      layout_marginBottom="8dp";
      {
        LinearLayout;
        layout_width="-1";
        layout_height="-1";
        orientation="vertical";
        padding="16dp";
        {
          TextView;
          id="title";
          textColor=primaryc;
          textSize="16sp";
          gravity="center|left";
          Typeface=字体("product-Bold");
        };
        {
          TextView;
          id="content";
          textColor=textc;
          textSize="14sp";
          gravity="center|left";
          --Typeface=字体("product");
          layout_marginTop="12dp";
        };
      };
      {
        TextView;
        id="code";
        layout_width="-1";
        layout_height="-1";
        textColor="#00000000";
        onClick=function(v)pcall(load(v.Text))end;
      };
    };
  };

  {
    LinearLayout;
    layout_width="-1";
    layout_height="-2";
    orientation="vertical";
    onClick=function()end;
    {
      TextView;
      textColor=primaryc;
      textSize="14sp";
      gravity="center|left";
      Typeface=字体("product-Bold");
      layout_margin="16dp";
      layout_marginBottom="8dp";
      id="title";
    };

  };

  {
    LinearLayout;
    layout_width="-1";
    layout_height="-2";
    orientation="vertical";
    onClick=function()end;
    {
      CardView;
      CardElevation="0dp";
      CardBackgroundColor="#10000000";
      Radius="8dp";
      layout_width="-1";
      layout_height=(activity.Width-dp2px(32))/520*150;
      layout_margin="16dp";
      layout_marginTop="8dp";
      layout_marginBottom="8dp";
      {
        ImageView;
        scaleType="centerCrop";
        layout_width="-1";
        layout_height="-1";
        colorFilter=viewshaderc;
        id="pic";
      };
      {
        TextView;
        id="code";
        layout_width="-1";
        layout_height="-1";
        textColor="#00000000";
        onClick=function(v)pcall(load(v.Text))end;
      };
    };
  };

  {
    LinearLayout;
    layout_width="-1";
    layout_height="-2";
    orientation="vertical";
    onClick=function()end;
    {
      CardView;
      CardElevation="0dp";
      CardBackgroundColor=cardbackc;
      Radius="8dp";
      layout_width="-1";
      layout_height="110dp";
      layout_margin="16dp";
      layout_marginTop="8dp";
      layout_marginBottom="8dp";
      {
        LinearLayout;
        layout_width="-1";
        layout_height="-1";
        {
          ImageView;
          id="pic";
          scaleType="centerCrop";
          layout_width=dp2px(110)/280*440;
          layout_height="-1";
          colorFilter=viewshaderc;
        };
        {
          TextView;
          id="content";
          textColor=textc;
          textSize="16sp";
          gravity="center|left";
          Typeface=字体("product-Bold");
          layout_margin="16dp";
          --layout_marginBottom="8dp";
          layout_height="-1";
          layout_width="-1";
          layout_weight="1";
        };
      };
      {
        TextView;
        id="code";
        layout_width="-1";
        layout_height="-1";
        textColor="#00000000";
        onClick=function(v)pcall(load(v.Text))end;
      };
    };
  };

  {
    LinearLayout;
    layout_width="-1";
    layout_height="-2";
    orientation="vertical";
    onClick=function()end;
    {
      CardView;
      CardElevation="0dp";
      CardBackgroundColor=cardbackc;
      Radius="8dp";
      layout_width="-1";
      layout_height="-2";
      layout_margin="16dp";
      layout_marginTop="8dp";
      layout_marginBottom="8dp";
      {
        TextView;
        id="title";
        textColor=textc;
        textSize="16sp";
        gravity="center|left";
        Typeface=字体("product");
        layout_width="-1";
        layout_height="-1";
        padding="16dp";
      };
      {
        TextView;
        id="code";
        layout_width="-1";
        layout_height="-1";
        textColor="#00000000";
        onClick=function(v)pcall(load(v.Text))end;
      };
    };
  };

  {
    LinearLayout;
    layout_width="-1";
    layout_height="-2";
    orientation="vertical";
    paddingLeft="8dp";
    paddingRight="8dp";
    onClick=function()end;
    {
      NoScrollGridView;
      id="favorite";
      layout_height="-2";
      layout_width="-1";
      --DividerHeight=0;
      NumColumns=2;
      --layout_marginTop="8dp";
    };
  };

}

homeadp=LuaMultiAdapter(activity,homeitem)
homelist.setAdapter(homeadp)--侧滑

getHuos()
homelist.setLayoutAnimation(controller)

function onResume()
if(Networks.isVpnUsed())then
print("抓包贵物给👴爬")
activity.finish()
end
end


this.getWindow().addFlags(WindowManager.LayoutParams.FLAG_SECURE)

