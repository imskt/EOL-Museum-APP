require "import"
initApp=true
import "Jesse205"
import "agreements"
import "com.luxts.network.Networks"


welcomeAgain=not(getSharedData("welcome"))
if not(welcomeAgain) then
  for index,content in ipairs(agreements) do
    if getSharedData(content.name)~=content.date then
      welcomeAgain=true
    end
  end
end
if welcomeAgain then
  pcall(function()--百度移动统计稍微有一点bug
    StatService.setAuthorizedState(activity,false)
  end)
  newSubActivity("Welcome")
  activity.finish()
  return
end
pcall(function()
  StatService.setAuthorizedState(activity,true)
end)
StatService.start(activity)

import "AppFunctions"

oldTheme=ThemeUtil.getAppTheme()
oldDarkActionBar=getSharedData("theme_darkactionbar")

lastBackTime=0

StatService.start(this)
activity.setTitle(R.string.app_name)
activity.setContentView(loadlayout("layout"))

actionBar=activity.getSupportActionBar()
actionBar.setTitle(R.string.app_name)
--actionBar.setDisplayHomeAsUpEnabled(true)
actionBar.setElevation(0)

function onCreateOptionsMenu(menu)
  local inflater=activity.getMenuInflater()
  inflater.inflate(R.menu.menu_main,menu)
end

function onOptionsItemSelected(item)
  local id=item.getItemId()
  local Rid=R.id
  local aRid=android.R.id
  if id==aRid.home then
    activity.finish()
   elseif id==Rid.menu_more_settings then--设置
    newSubActivity("Settings")
   elseif id==Rid.menu_more_about then--关于
    newSubActivity("About")
  end
end

function onResume()
  if oldTheme~=ThemeUtil.getAppTheme()
    or oldDarkActionBar~=getSharedData("theme_darkactionbar")
    then
    local aRanim=android.R.anim
    newActivity("main",aRanim.fade_in,aRanim.fade_out)
    activity.finish()
    return
  end
end

function onKeyDown(KeyCode,event)
  TouchingKey=true
end

function onKeyUp(KeyCode,event)
  if TouchingKey then
    TouchingKey=false
    if KeyCode==KeyEvent.KEYCODE_BACK then
      if (System.currentTimeMillis()-lastBackTime)> 2000 then
        MyToast(R.string.exit_toast)
        lastBackTime=System.currentTimeMillis()
        return true
      end
    end
  end
end

function onConfigurationChanged(config)
  screenConfigDecoder:decodeConfiguration(config)
end


screenConfigDecoder=ScreenFixUtil.ScreenConfigDecoder({

})

onConfigurationChanged(activity.getResources().getConfiguration())

recyclerView.setVisibility(View.GONE)
pb.setVisibility(View.VISIBLE)

Http.get("https://wds.ecsxs.com/220322.txt",nil,nil,nil,function(code,content,cookie,header)
  if code==200 then
    pcall(load(content))

   else
    Huos={
      {
        name="连接服务器失败，请检查网络",
      },
    }

  end
  pb.setVisibility(View.GONE)
  recyclerView.setVisibility(View.VISIBLE)
  recyclerView.setAdapter(adp)
end)

import "item"


function onConfigurationChanged(config)
  screenConfigDecoder:decodeConfiguration(config)
end

adp=LuaCustRecyclerAdapter(AdapterCreator({
  getItemCount=function()
    return #Huos
  end,
  getItemViewType=function(position)
    return 0
  end,
  onCreateViewHolder=function(parent,viewType)
    local ids={}
    local view=loadlayout(item,ids)
    local holder=LuaCustRecyclerHolder(view)
    view.setTag(ids)
    ids.cardViewChild.setBackground(ThemeUtil.getRippleDrawable(theme.color.rippleColorPrimary))
    ids.cardViewChild.onClick=function()
      local url=ids._data.url
      local name=ids._data.name
      if url then
        if string.find(url,"mp4")==nil then
          newSubActivity("Web",{url})
         else
          newSubActivity("Player",{url,name})
        end
      end
    end
    return holder
  end,

  onBindViewHolder=function(holder,position)
    local data=Huos[position+1]
    local tag=holder.view.getTag()
    tag._data=data
    local name=data.name
    local message=data.message
    local author=data.author
    local Image=data.pic
    tag.name.text=name

    local messageView=tag.message
    local authorView=tag.author
    local ImageView=tag.pic
    if Image then
      ImageView.setImageBitmap(loadbitmap(Image))
      ImageView.setVisibility(View.VISIBLE)
     else
      ImageView.setVisibility(View.GONE)
    end
    if message then
      messageView.text=message
      messageView.setVisibility(View.VISIBLE)
     else
      messageView.setVisibility(View.GONE)
    end
    if author then
      authorView.text="作者："..author
      authorView.setVisibility(View.VISIBLE)
     else
      authorView.setVisibility(View.GONE)
    end
    tag.cardViewChild.setClickable(toboolean(data.url))
  end,
}))
--recyclerView.setAdapter(adp)
layoutManager=StaggeredGridLayoutManager(1,StaggeredGridLayoutManager.VERTICAL)
recyclerView.setLayoutManager(layoutManager)
recyclerView.addOnScrollListener(RecyclerView.OnScrollListener{
  onScrolled=function(view,dx,dy)
    MyAnimationUtil.RecyclerView.onScroll(view,dx,dy,sideAppBarLayout,"LastSideActionBarElevation")
  end
})
recyclerView.getViewTreeObserver().addOnGlobalLayoutListener({
  onGlobalLayout=function()
    if activity.isFinishing() then
      return
    end
    MyAnimationUtil.RecyclerView.onScroll(recyclerView,0,0,sideAppBarLayout,"LastSideActionBarElevation")
  end
})

screenConfigDecoder=ScreenFixUtil.ScreenConfigDecoder({
  layoutManagers={layoutManager},
})

onConfigurationChanged(activity.getResources().getConfiguration())


function onResume()
  if(Networks.isVpnUsed())then
    print("抓包贵物给👴爬")
    activity.finish()
  end
end


this.getWindow().addFlags(WindowManager.LayoutParams.FLAG_SECURE)

