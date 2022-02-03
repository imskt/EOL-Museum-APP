require "import"
import "android.app.*"
import "android.os.*"
import "android.widget.*"
import "android.view.*"
import "android.graphics.PorterDuff"
import "android.graphics.PorterDuffColorFilter"
import "android.media.MediaPlayer"
import "android.widget.MediaController"
import "android.net.Uri"
import "android.view.animation.TranslateAnimation"
import "android.graphics.drawable.ColorDrawable"
import "android.graphics.*"
import "android.util.DisplayMetrics"
import "android.content.Context"
import "android.content.Context"
import "android.graphics.PixelFormat"
import "android.animation.ObjectAnimator"

--导入第三方库
import "com.sprylab.android.widget.TextureVideoView"



loadingDrawable=LuaDrawable(function(mCanvas,mPaint,mDrawable)
  mPaint.setColor(0xffffffff)
  mPaint.setAntiAlias(true)
  mPaint.setStrokeWidth(28)
  mPaint.setStyle(Paint.Style.STROKE)
  mPaint.setStrokeCap(Paint.Cap.ROUND)
  w=mDrawable.getBounds().right
  h=mDrawable.getBounds().bottom
  b=RectF(w/2-50,h/2-50,w/2+50,h/2+50)
  local n=0
  local m=0
  local sn=6
  local sm=2
  return function(mCanvas)
    if n>360 then
      sm=sm+sn
      sn=0-sn
     elseif n<0 then
      sn=6
      sm=2
    end
    n=n+sn
    m=(m+sm)%360
    mCanvas.drawArc(b,m,n,false,mPaint)
    mDrawable.invalidateSelf()
  end
end)




--dp转px
function dpTopx(sdp)
  import "android.util.TypedValue"
  dm=this.getResources().getDisplayMetrics()
  types={px=0,dp=1,sp=2,pt=3,["in"]=4,mm=5}
  n,ty=sdp:match("^(%-?[%.%d]+)(%a%a)$")
  return TypedValue.applyDimension(types[ty],tonumber(n),dm)
end


--横屏时获取屏幕宽度(包括导航栏)
function getRealWidth()
  windowManager = activity.getApplication().getInstance().getSystemService(Context.WINDOW_SERVICE);
  display = windowManager.getDefaultDisplay();
  dm = DisplayMetrics();
  if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR1) then
    display.getRealMetrics(dm);
   else
    display.getMetrics(dm);
  end
  --realHeight = dm.heightPixels;
  realWidth = dm.widthPixels;
  return realWidth;
end


--传入毫秒(毫秒转时间)
function getTimeStr(time)

  --[[
  import "java.text.SimpleDateFormat"
  import "java.text.DateFormat"
  import "java.util.Date"
  date = Date(time)
  sdf = SimpleDateFormat("hh:mm:ss")
  
  return sdf.format(date)
  ]]

  hours = math.floor((time % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
  minutes = math.floor((time % (1000 * 60 * 60)) / (1000 * 60));
  seconds = math.floor((time % (1000 * 60)) / 1000);

  if hours<=9 then

    hours="0"..hours

  end

  if minutes<=9 then

    minutes="0"..minutes

  end

  if seconds<=9 then

    seconds="0"..seconds

  end

  return hours..":"..minutes..":"..seconds
  
end


