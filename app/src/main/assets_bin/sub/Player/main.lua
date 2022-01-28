require "import"
import "android.app.*"
import "android.os.*"
import "android.widget.*"
import "android.view.*"
import "android.media.MediaPlayer"
import "android.view.GestureDetector"
import "java.io.File"
import "android.content.res.Configuration"
import "android.content.Context"
import "android.media.AudioManager"
import "com.luxts.network.Networks"


activity.setContentView(loadlayout("layout"))
window=activity.getWindow()
window.setNavigationBarColor(0xff000000)

path,videoname=...


playbitmap=loadbitmap("res/ic_play_arrow_black_24dp.png")
pausebitmap=loadbitmap("res/ic_pause_black_24dp.png")
P2L=loadbitmap("res/ic_fullscreen_black_24dp.png")
L2P=loadbitmap("res/ic_fullscreen_exit_black_24dp.png")
--P2L=loadbitmap("res/P2L.jpg")
--L2P=loadbitmap("res/L2P.jpg")

SpeedTable={0.5,0.75,1.0,1.25,1.5}
SpeedIndex=3
mVolume=0.5

--毫秒转分:秒格式
function ms2minsec(t)
  local s=t/1000
  local sec=tointeger(s%60)
  if sec<10 then
    sec="0"..sec
  end
  local min=tointeger(s//60)
  if min<10 then
    min="0"..min
  end
  return min..":"..sec
end

--小数转百分数
function dec2per(n)
  return tointeger(100*n).."%"
end

function dectoper(n)
  return tointeger(100*n)
end

function ButtonFrame(view,Thickness,FrameColor,InsideColor)
  import "android.graphics.drawable.GradientDrawable"
  drawable=GradientDrawable()
  drawable.setShape(GradientDrawable.RECTANGLE)
  drawable.setStroke(Thickness, FrameColor)
  drawable.setColor(InsideColor)
  view.setBackgroundDrawable(drawable)
end
ButtonFrame(SpeedBtn,2,-1,0x00000000)


AWidth=activity.getWidth()
AHeight=activity.getHeight()
if this.getResources().getConfiguration().orientation==Configuration.ORIENTATION_LANDSCAPE then
  directbtn.setImageBitmap(L2P)
 else
  directbtn.setImageBitmap(P2L)
end

--由焦点变量focus控制是否显示titlebar，controlbar
--focusdelay为0时，ti2会隐藏顶栏，底栏，虚拟导航栏，否则每秒-1
focus=true
focusdelay=3
function setunfocus()
  focus=false
  titlebar.setVisibility(View.GONE)
  controlbar.setVisibility(View.GONE)
  --activity.getDecorView().setSystemUiVisibility(View.SYSTEM_UI_FLAG_HIDE_NAVIGATION|View.SYSTEM_UI_FLAG_IMMERSIVE)
end

function setfocus()
  focus=true
  titlebar.setVisibility(View.VISIBLE)
  controlbar.setVisibility(View.VISIBLE)
  --activity.getDecorView().setSystemUiVisibility(0)
  --重置focusdelay
  focusdelay=3
end


function ChangeSurfaceSize()
  VideoWidth=mediaPlayer.getVideoWidth()
  VideoHeight=mediaPlayer.getVideoHeight()
  scale=math.min(AWidth/VideoWidth,AHeight/VideoHeight)
  layoutParams=mSurfaceView.getLayoutParams()
  layoutParams.width=VideoWidth*scale
  layoutParams.height=VideoHeight*scale
  mSurfaceView.setLayoutParams(layoutParams)
end

function onConfigurationChanged(config)
  AWidth=activity.getWidth()
  AHeight=activity.getHeight()
  ChangeSurfaceSize()
  if config.orientation==Configuration.ORIENTATION_LANDSCAPE then

    directbtn.setImageBitmap(L2P)
   else

    directbtn.setImageBitmap(P2L)
  end
end

function AutoRotate(VideoWidth,VideoHeight)
  if VideoWidth>VideoHeight then
    activity.setRequestedOrientation(0)
   else
    activity.setRequestedOrientation(1)
  end
end



mediaPlayer=MediaPlayer()
mediaPlayer.reset()
mediaPlayer.setScreenOnWhilePlaying(true)
--activity.getSystemService(Context.AUDIO_SERVICE).setStreamVolume(AudioManager.STREAM_MUSIC,tonumber(dectoper(mVolume))/4, AudioManager.FLAG_SHOW_UI)


--缓冲完成的监听
mediaPlayer.setOnPreparedListener(MediaPlayer.OnPreparedListener{
  onPrepared=function(mediaPlayer)
    --开始播放
    Prepared=true
    playbtn.setEnabled(true)
    seekBar.setEnabled(true)
    VideoWidth=mediaPlayer.getVideoWidth()
    VideoHeight=mediaPlayer.getVideoHeight()
    AutoRotate(VideoWidth,VideoHeight)
    videoduration=mediaPlayer.Duration
    seekBar.setMax(videoduration)
    endtime.Text=ms2minsec(videoduration)
    ChangeSurfaceSize()
    if isNetFile then
      BufferMsg.setVisibility(View.GONE)
    end
    Play()
  end
})

--进度跳转完成监听
mediaPlayer.setOnSeekCompleteListener(MediaPlayer.OnSeekCompleteListener{
  onSeekComplete=function(mediaPlayer)
    --print("跳转完成")
  end
})

--网络流媒体的缓冲变化时回调
mediaPlayer.setOnBufferingUpdateListener(MediaPlayer.OnBufferingUpdateListener{
  onBufferingUpdate=function(mediaPlayer,BufferPercent)
    seekBar.setSecondaryProgress(BufferPercent/100*videoduration)
  end
})

--播放完成回调
mediaPlayer.setOnCompletionListener(MediaPlayer.OnCompletionListener{
  onCompletion=function(mediaPlayer)
    if Prepared then

      playbtn.setImageBitmap(playbitmap)
      --播放完毕的时间偶尔会达不到总时长，需要在完成监听里纠正
      currenttime.Text=ms2minsec(videoduration)
    end
  end
})

--信息回调
mediaPlayer.setOnInfoListener(MediaPlayer.OnInfoListener{
  onInfo=function(mediaPlayer,what,extra)
    switch what
     case MediaPlayer.MEDIA_INFO_VIDEO_RENDERING_START

     case MediaPlayer.MEDIA_INFO_BUFFERING_START then
      if isNetFile then
        BufferText.Text="正在缓冲"
        BufferMsg.setVisibility(View.VISIBLE)
      end
     case MediaPlayer.MEDIA_INFO_BUFFERING_END
      --print("缓冲完成")
      if isNetFile then
        BufferMsg.setVisibility(View.GONE)
      end
     case MediaPlayer.MEDIA_INFO_VIDEO_TRACK_LAGGING
      print("视频过于复杂解码太慢")

    end
  end
})

--错误回调
mediaPlayer.setOnErrorListener(MediaPlayer.OnErrorListener{
  onError=function(mediaPlayer,what,extra)
    switch what
     case MediaPlayer.MEDIA_ERROR_UNKNOWN
      print("位置错误")
     case MediaPlayer.MEDIA_ERROR_SERVER_DIED
      print("服务器错误")
     default
      print(what)
    end
    switch extra
     case MediaPlayer.MEDIA_ERROR_IO
      print("本地文件或网络相关错误")
     case MediaPlayer.MEDIA_ERROR_TIME_OUT
      print("一些操作超时")
     case MediaPlayer.MEDIA_ERROR_MALFORMAD
      print("比特流不符合相关的编码标准和文件规范")
     case MediaPlayer.MEDIA_ERROR_UNSUPPORTED
      print("框架不支持该功能")
     default
      print(extra)
    end
    activity.finish()
  end
})




if Build.VERSION.SDK_INT<23 then
  SpeedBtn.setVisibility(View.GONE)
end
function ChangePlayerSpeed(speed)
  if Build.VERSION.SDK_INT>=23 then
    if mediaPlayer.isPlaying() then
      mediaPlayer.setPlaybackParams(mediaPlayer.getPlaybackParams().setSpeed(speed))
     else
      mediaPlayer.setPlaybackParams(mediaPlayer.getPlaybackParams().setSpeed(speed))
      mediaPlayer.pause()
    end
  end
end




ti2=Ticker()
ti2.Period=1000
ti2.onTick=function()
  if focusdelay==0 then
    if not(isSeekbarTracking) and focus then
      setunfocus()
    end
   else
    focusdelay=focusdelay-1
  end
  if mediaPlayer and mediaPlayer.isPlaying() then
    currentposition=mediaPlayer.getCurrentPosition()
    currenttime.Text=ms2minsec(currentposition)
    if not(isSeekbarTracking)
      seekBar.setProgress(currentposition)
    end
  end
end
ti2.start()

function PreparePlay(path)
  playbtn.setEnabled(false)
  seekBar.setEnabled(false)
  isNetFile=path:find("http")
  if isNetFile then
    BufferText.Text="正在连接"
    BufferMsg.setVisibility(View.VISIBLE)
  end
  Prepared=false
  --设置播放资源
  mediaPlayer.setDataSource(path)
  title.Text=videoname
  videoduration=0
  --开始缓冲资源
  mediaPlayer.prepareAsync()
end

holder=mSurfaceView.getHolder()
holder.addCallback(SurfaceHolder_Callback{
  surfaceCreated=function(holder)
    mediaPlayer.setDisplay(holder)
    if isPlayingWhenDestroyed then
      Play()
    end
  end,
  surfaceDestroyed=function(holder)
    isPlayingWhenDestroyed=mediaPlayer.isPlaying()
    Pause()
  end
})



function getLight()
  local lp=activity.getWindow().getAttributes()
  if lp.screenBrightness<0 then
    --小于0时为默认亮度,不清楚是多少,暂定为0.5
    return 0.5
   else
    return lp.screenBrightness
  end
end

--设置窗口亮度
--0<=brightness<=1
function setLight(brightness)
  local lp=activity.getWindow().getAttributes()
  lp.screenBrightness=brightness
  activity.getWindow().setAttributes(lp)
end

mOnGestureListener=GestureDetector.OnGestureListener{

  onDown=function(e)
    --记录按下时的X坐标，不清楚和下面e1.getX()的区别
    downX=e.getX()
    return true
  end,

  --滑动
  onScroll=function(e1,e2,distanceX,distanceY)

    --注意if执行完以后任然存在ScrollMode=nil的可能
    if not(ScrollMode) then
      --如果ScrollMode为空,那么判断并赋值ScrollMode
      if math.abs(e1.getX()-e2.getX())>math.abs(e1.getY()-e2.getY()) then
        --如果起步时横向滑动大于纵向,那么判定进度拖动
        if Prepared then
          ScrollMode=1
        end
       else
        if downX<AWidth/3 then
          --判定左侧上下滑动
          ScrollMode=2
          --刚开始滑动时获取当前窗口亮度
          screenBrightness=getLight()
         elseif downX>2*AWidth/3 then
          --判定右侧上下滑动
          ScrollMode=3
        end
      end
    end

    switch ScrollMode
     case 1
      --滑动时保持控制栏区域可见
      if not(focus) then
        setfocus()
      end
      isSeekbarTracking=true
      msg.setVisibility(View.VISIBLE)
      progress=progress-videoduration*distanceX/AWidth/2
      progress=math.max(0,progress)
      progress=math.min(progress,videoduration)
      --会触发seekBar的onProgressChanged
      --但不触发onStopTrackingTouch，所以还要写ACTION_UP事件
      seekBar.setProgress(progress)

     case 2
      msg.setVisibility(View.VISIBLE)
      screenBrightness=screenBrightness+distanceY/AHeight*2
      screenBrightness=math.max(0,screenBrightness)
      screenBrightness=math.min(screenBrightness,1)
      msg.setText("亮度\n"..dec2per(screenBrightness))
      --滑动时实时调整亮度
      setLight(screenBrightness)

     case 3
      msg.setVisibility(View.VISIBLE)
      mVolume=mVolume+distanceY/AHeight*2
      mVolume=math.max(0,mVolume)
      mVolume=math.min(mVolume,1)
      msg.setText("音量\n"..dec2per(mVolume))
      --滑动时实时调整音量
      activity.getSystemService(Context.AUDIO_SERVICE).setStreamVolume(AudioManager.STREAM_MUSIC,tonumber(dectoper(mVolume))/4, AudioManager.FLAG_SHOW_UI)
    end

    return true
  end,
}

mOnDoubleTapListener=GestureDetector.OnDoubleTapListener{

  --纯单击
  onSingleTapConfirmed=function(e)

    --（通过单击DOWN后300ms没有下一个DOWN事件确认）
    --这不是一个双击事件，而是一个单击事件的时候会回调
    if focus then
      setunfocus()
     else
      setfocus()
    end
    return true
  end,

  --纯双击
  onDoubleTap=function(e)
    if Prepared then
      if mediaPlayer.isPlaying() then

        Pause()
       else

        Play()
      end
    end
    return true
  end,
}

--一般事件检测
mGestureDetector=GestureDetector(this,mOnGestureListener)

--单双击检测
mGestureDetector.setOnDoubleTapListener(mOnDoubleTapListener)

fl.onTouch=function(view,event)

  --手指离开屏幕时更改视频进度
  if event.getAction()==MotionEvent.ACTION_UP then

    if ScrollMode then
      ScrollMode=nil
      msg.setVisibility(View.GONE)
    end

    if isSeekbarTracking then
      mediaPlayer.seekTo(progress)
      currenttime.Text=ms2minsec(progress)
      isSeekbarTracking=false
      focusdelay=3
      if isNetFile then
        BufferText.Text="正在跳转"
        BufferMsg.setVisibility(View.VISIBLE)
      end
    end
  end

  --把tv的event事件传给mGestureDetector
  --让它来判断事件
  return mGestureDetector.onTouchEvent(event);

end




function Play()
  if Prepared then

    mediaPlayer.start()
    playbtn.setImageBitmap(pausebitmap)
  end
end

function Pause()

  mediaPlayer.pause()
  playbtn.setImageBitmap(playbitmap)
end

playbtn.onClick=function(v)
  focusdelay=3
  if mediaPlayer.isPlaying() then

    Pause()
   else

    Play()
  end
end

backbtn.onClick=function(v)
  activity.finish()
end

directbtn.onClick=function(v)
  if this.getResources().getConfiguration().orientation==Configuration.ORIENTATION_LANDSCAPE then
    activity.setRequestedOrientation(1)
   else
    activity.setRequestedOrientation(0)
  end
end

directbtn.onLongClick=function(v)
  --2代表跟随系统方向旋转
  activity.setRequestedOrientation(2)
  print("解除方向锁定")
  return true
end

seekBar.setOnSeekBarChangeListener{
  onStartTrackingTouch=function(seekBar)
    msg.setVisibility(View.VISIBLE)
    isSeekbarTracking=true
    focusdelay=3
  end,
  onProgressChanged=function(seekBar)
    progress=seekBar.getProgress()
    msg.Text="跳转进度\n"..ms2minsec(progress)
  end,
  onStopTrackingTouch=function(seekBar)
    msg.setVisibility(View.GONE)
    mediaPlayer.seekTo(progress)
    currenttime.Text=ms2minsec(progress)
    isSeekbarTracking=false
    focusdelay=3
    if isNetFile then
      BufferText.Text="正在跳转"
      BufferMsg.setVisibility(View.VISIBLE)
    end
  end,
}




SpeedBtn.onClick=function(v)
  SpeedDialog=AlertDialog.Builder(this)
  .setTitle("变速播放")
  .setSingleChoiceItems(String(SpeedTable),SpeedIndex-1,
  {onClick=function(dialog,p)
      SpeedIndex=p+1
      ChangePlayerSpeed(SpeedTable[SpeedIndex])
      SpeedBtn.Text="X"..SpeedTable[SpeedIndex]
      print(SpeedTable[SpeedIndex].."倍速")
      dialog.dismiss()
  end})
  SpeedDialog.onDismiss=function()
    Play()
  end
  SpeedDialog.show()
  Pause()
end



function onDestroy()
  mediaPlayer.release()
  mediaPlayer=nil
  ti2.stop()
end


activity.getSupportActionBar().hide()
local window = activity.getWindow();
window.getDecorView().setSystemUiVisibility(View.SYSTEM_UI_FLAG_FULLSCREEN|
View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN|
View.SYSTEM_UI_FLAG_HIDE_NAVIGATION|
View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY);
window.addFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN)

xpcall(function()
  local lp = window.getAttributes();
  lp.layoutInDisplayCutoutMode = WindowManager.LayoutParams.LAYOUT_IN_DISPLAY_CUTOUT_MODE_SHORT_EDGES;
  window.setAttributes(lp);
  lp=nil
end,
function(e)
end)
window=nil

if not(pcall(PreparePlay,path)) then
  print("视频不存在")
end

function onResume()
  if(Networks.isVpnUsed())then
    print("抓包贵物给👴爬")
    activity.finish()
  end
end


this.getWindow().addFlags(WindowManager.LayoutParams.FLAG_SECURE)