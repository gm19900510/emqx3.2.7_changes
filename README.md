# emqx3.2.7_changes
> 用于emqx开源版持久化恢复的相关变更项

## 说明

- 环境安装
 参照：https://blog.csdn.net/ctwy291314/article/details/104550966
 
- emqx修改项说明
 
 emqx_app.erl
 
 > start方法新增register(emqx, spawn(?MODULE, loop, [])),线程消息监听
 
 > start方法修改原启动时开启全部监听端口，改为开启内部端口11883
 
 > 新增call、loop方法接受到线程消息后关闭内部监听端口11883，开启全部端口
 
 emqx_listeners.erl
 
 新增日志输出
 
- emqx-web-hook修改项说明
 
 emqx_web_hook.erl
 
 > load方法新增线程消息监听
 
 > 新增loop方法进行UDP传输
 
 > on_message_publish方法改为调用线程消息传输和Retain==true判定
 
- emqx-management修改项说明
 
 > emqx_mgmt_api_pubsub.erl
 
 > publish_batch方法新增emqx_app:call("restart")消息触发
 

## 资料
- https://github.com/gm19900510/emqx_restart_resume_v2
- https://github.com/emqx/emqx-web-hook/
- https://github.com/emqx/emqx-enterprise-docs-cn/blob/master/rest.rst
- https://blog.csdn.net/ctwy291314/article/details/104550966
- https://blog.csdn.net/ctwy291314/article/details/104965786






