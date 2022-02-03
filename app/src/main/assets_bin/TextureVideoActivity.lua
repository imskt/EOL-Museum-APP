require "import"
import "tools"
import "com.luxts.network.Networks"

--接收传递过来的数据,并处理数据
url,title=...
title=tostring(title)


--获得布局
function getLayout(MyPlayerWidth,MyPlayerHeight)

  --播放器布局
  layout=loadlayout({
    FrameLayout,
    layout_height="fill",
    layout_width="fill",

    --播放器核心界面
    {
      LinearLayout,
      layout_height=MyPlayerHeight,
      layout_width=MyPlayerWidth,
      background="#000000",
      gravity="center",
      id="fl2",
      {
        TextureVideoView,
        layout_height="fill",
        layout_width="fill",
        id="mVideoView",
      },
    },

    --上控制台布局
    {
      LinearLayout,
      layout_height=MyPlayerHeight,
      layout_width=MyPlayerWidth,
      id="fl3",
      {
        LinearLayout,
        layout_height="56dp",
        layout_width="fill",
        background="imgs/gradient_top.png",
        id="sll",
        {
          ImageView,
          layout_height="56dp",
          layout_width="56dp",
          colorFilter="#ffffff",
          padding="18dp",
          src="imgs/off.png",
          onClick=function()
            activity.finish()
          end
        },
        {
          TextView,
          layout_height="56dp",
          layout_weight=1,
          textColor="#ffffff",
          Gravity="center|left",
          text=title,
          textSize="13dp",
        },
      },
    },


    --下控制台布局
    {
      LinearLayout,
      layout_height=MyPlayerHeight,
      layout_width=MyPlayerWidth,
      Gravity="bottom",
      id="fl4",
      {
        LinearLayout,
        layout_height="56dp",
        layout_width="fill",
        background="imgs/gradient_bottom.png",
        id="xll",

        {
          ImageView,
          layout_height="56dp",
          layout_width="56dp",
          colorFilter="#ffffff",
          padding="18dp",
          src="imgs/zt.png",
          id="playBtn",
        },


        {
          LinearLayout,
          layout_height="56dp",
          layout_weight=1,
          orientation="vertical",
          Gravity="center|top",
          {
            SeekBar,
            layout_height="30dp",
            layout_width="fill",
            paddingStart="10dp",
            paddingEnd="10dp",
            id="playSeekBar",
          },
          {
            LinearLayout,
            layout_width="fill",
            layout_height="20dp",
            {
              TextView,
              layout_height="20dp",
              layout_weight=1,
              textColor="#ffffff",
              paddingLeft="10dp",
              Gravity="center|left",
              text="00:00:00",
              textSize="8dp",
              id="dctv",
            },
            {
              TextView,
              layout_height="20dp",
              layout_weight=1,
              textColor="#ffffff",
              paddingRight="10dp",
              Gravity="center|right",
              text="00:00:00",
              textSize="8dp",
              id="ztv",
            },
          },
        },
        {
          TextView,
          layout_height="56dp",
          layout_width="56dp",
          padding="18dp",

        },

      },
    },

    --加载动画布局
    {
      LinearLayout,
      layout_height=MyPlayerHeight,
      layout_width=MyPlayerWidth,
      id="load",
    },

    --自定义布局

  })

  return layout

end


function init()
  --定时器
  MyTicker=Ticker()

  MyTicker.Period=100
  --当前播放进度
  CurrentPosition=0

  mVideoView.setOnPreparedListener(MediaPlayer.OnPreparedListener{

    onPrepared=function(mp)

      load.setVisibility(View.INVISIBLE)

      mVideoView.start()

      --获取视频总时间
      duration=mVideoView.getDuration()

      playSeekBar.setMax(duration)

      ztv.Text=getTimeStr(duration)

      playSeekBar.setProgress(0)

      MyTicker.start()

      MyTicker.onTick=function()

        CurrentPosition=mVideoView.getCurrentPosition()

        dctv.Text=getTimeStr(CurrentPosition)

        if CurrentPosition==duration then

          MyTicker.stop()

        end

        playSeekBar.setProgress(CurrentPosition)

      end

    end

  });


  mVideoView.setOnInfoListener(MediaPlayer.OnInfoListener {

    onInfo=function(mp,what,extra)

      --正在缓冲
      if what==MediaPlayer.MEDIA_INFO_BUFFERING_START then

        load.setVisibility(View.VISIBLE)

        --缓冲完成,开始播放
       elseif what==MediaPlayer.MEDIA_INFO_BUFFERING_END then

        load.setVisibility(View.INVISIBLE)

      end

      return true;

    end

  });


  mVideoView.setOnErrorListener(MediaPlayer.OnErrorListener{

    onError=function(mp,what,extra)

      switch what

       case MediaPlayer.MEDIA_ERROR_IO

        print("文件不存在或错误，或网络不可访问错误")

       case MediaPlayer.MEDIA_ERROR_MALFORMED

        print("流不符合有关标准或文件的编码规范")

       case MediaPlayer.MEDIA_ERROR_SERVER_DIED

        print("服务器错误")

       case MediaPlayer.MEDIA_ERROR_TIMED_OUT

        print("网络超时")

       case MediaPlayer.MEDIA_ERROR_UNKNOWN

        print("未知错误,请检查网络和服务器")

      end

      return true

    end

  });


  mVideoView.setOnCompletionListener(MediaPlayer.OnCompletionListener{

    onCompletion=function(mp)

      print("播放完成")

      mVideoView.pause()

      playBtn.setImageBitmap(loadbitmap(activity.getLuaDir().."/imgs/bf.png"))

    end

  });


  --播放暂停按钮
  playBtn.onClick=function()

    if mVideoView.isPlaying() then

      mVideoView.pause()

      playBtn.setImageBitmap(loadbitmap(activity.getLuaDir().."/imgs/bf.png"))

     else

      mVideoView.start()

      playBtn.setImageBitmap(loadbitmap(activity.getLuaDir().."/imgs/zt.png"))

    end

  end

  playSeekBar.ProgressDrawable.setColorFilter(PorterDuffColorFilter(0xFFFFFFFF,PorterDuff.Mode.SRC_ATOP))

  playSeekBar.Thumb.setColorFilter(PorterDuffColorFilter(0xFFFFFFFF,PorterDuff.Mode.SRC_ATOP))

  playSeekBar.setOnSeekBarChangeListener{

    onStartTrackingTouch=function(SeekBar,progress)
      --使用手拖动
      UseHand=true

    end,

    onProgressChanged=function(SeekBar,progress)

      myProgress=progress

    end,

    onStopTrackingTouch=function(SeekBar)

      if UseHand==true then

        mVideoView.seekTo(myProgress)

        CurrentPosition=myProgress

        UseHand=false

      end

    end
  }

  --动态修改播放器宽高
  function setPlayerWH(MyPlayerWidth,MyPlayerHeight)

    ViewParams = fl2.getLayoutParams();

    ViewParams.width = MyPlayerWidth;

    ViewParams.height = MyPlayerHeight;

    fl2.setLayoutParams(ViewParams);

    fl3.setLayoutParams(ViewParams);

    fl4.setLayoutParams(ViewParams);

    load.setLayoutParams(ViewParams);

  end


  --控制台关闭动画
  local function ConsoleCloseAnim()

    sll.setVisibility(View.INVISIBLE)

    xll.setVisibility(View.INVISIBLE)

    Translate_down=TranslateAnimation(0, 0, 0, -dpTopx("56dp"))

    Translate_down.setDuration(500)

    sll.startAnimation(Translate_down)

    Translate_up=TranslateAnimation(0, 0, 0, dpTopx("56dp"))

    Translate_up.setDuration(500)

    xll.startAnimation(Translate_up)

  end


  --控制台开启动画
  local function ConsoleStartAnim()

    sll.setVisibility(View.VISIBLE)

    xll.setVisibility(View.VISIBLE)

    Translate_down=TranslateAnimation(0, 0, -dpTopx("56dp"), 0)

    Translate_down.setDuration(500)

    sll.startAnimation(Translate_down)

    Translate_up=TranslateAnimation(0, 0, dpTopx("56dp"), 0)

    Translate_up.setDuration(500)

    xll.startAnimation(Translate_up)

  end




  --播放界面点击事件
  local function ConsoleAnim()

    if sll.getVisibility()==0 then

      if AutoShutDownTicker then

        AutoShutDownTicker.stop()

        AutoShutDownTicker=nil

      end

      ConsoleCloseAnim()

     else

      ConsoleStartAnim()

      --判断有没有旧的定时器,销毁旧的,创建新的
      if AutoShutDownTicker then

        AutoShutDownTicker.stop()

        AutoShutDownTicker=nil

        AutoShutDownTicker=Ticker()

        AutoShutDownTicker.Period=100

        AutoShutDownTicker.start()

        AutoShutDownTime=100

        AutoShutDownTicker.onTick=function()

          if AutoShutDownTime==2000 then

            ConsoleCloseAnim()

            AutoShutDownTicker.stop()

          end

          AutoShutDownTime=AutoShutDownTime+100

        end

       else

        AutoShutDownTicker=Ticker()

        AutoShutDownTicker.Period=100

        AutoShutDownTicker.start()

        AutoShutDownTime=100

        AutoShutDownTicker.onTick=function()

          if AutoShutDownTime==2000 then

            ConsoleCloseAnim()

            AutoShutDownTicker.stop()

          end

          AutoShutDownTime=AutoShutDownTime+100

        end

      end

    end

  end




  --控件滑动监听(在这里可以添加视频播放器滑动快进或者音量调节)
  fl2.onTouch=function(view,event)

    a=event.getAction()&255

    switch a
      --按下
     case MotionEvent.ACTION_DOWN

      ConsoleAnim()
      --移动
     case MotionEvent.ACTION_MOVE

      --松手
     case MotionEvent.ACTION_UP

    end

    return true
  end



  --Activity退出暂停
  function onPause()

    mVideoView.pause();

    playBtn.setImageBitmap(loadbitmap(activity.getLuaDir().."/imgs/bf.png"))

    if AutoShutDownTicker then

      AutoShutDownTicker.stop()

      AutoShutDownTicker=nil

    end

  end

  mVideoView.setVideoURI(Uri.parse(url))

  load.background=loadingDrawable

  sll.setVisibility(View.INVISIBLE)

  xll.setVisibility(View.INVISIBLE)

end

--初始化界面
activity.setContentView(getLayout(activity.width,activity.width*0.55))

--初始化视频播放功能
init()

--设置主题,目的:隐藏状态栏,隐藏导航栏
activity.setTheme(android.R.style.Theme_Material_NoActionBar_Fullscreen)

activity.getSupportActionBar().hide()
activity.getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, WindowManager.LayoutParams.FLAG_FULLSCREEN);

activity.getDecorView().setSystemUiVisibility(View.SYSTEM_UI_FLAG_HIDE_NAVIGATION|View.SYSTEM_UI_FLAG_IMMERSIVE)
--设置横屏(用户自动切换)
activity.setRequestedOrientation(6)
--获取横屏时的宽度
MyPlayerWidth=getRealWidth()

MyPlayerHeight=activity.width

setPlayerWH(MyPlayerWidth,MyPlayerHeight)

function onResume()
if(Networks.isVpnUsed())then
print("抓包贵物给👴爬")
activity.finish()
end
end


this.getWindow().addFlags(WindowManager.LayoutParams.FLAG_SECURE)