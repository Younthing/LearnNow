# LearnNow CloudKit 部署

LearnNow 使用 Private CloudKit 数据库 `iCloud.fanxi.LearnNow`。课程内容不上传 CloudKit；个人进度、XP 事件、复习日志、卡片偏好与个人资料偏好由 SwiftData 自动同步，FSRS 当前状态缓存只保存在设备本地。

## 订阅要求

云同步是订阅权益：需要有效的月订或年订（`fanxi.LearnNow.cloudsync.monthly` / `fanxi.LearnNow.cloudsync.yearly`）且用户在设置中打开云同步偏好后，启动时才会挂接 CloudKit。

生效规则：`activeCloudSync = preference && isSubscribed`。偏好默认关闭；未订阅时设置页显示「升级以开启云同步」，已订阅后才显示真实开关。关闭偏好、订阅过期或撤销后，下次启动不再挂接 CloudKit；本机与 iCloud 中已有记录都不会被删除。课程学习、Anki 复习与路径本身保持免费，不设付费墙。

本地调试可使用 `LearnNow/Configuration/LearnNow.storekit`（已挂到 LearnNow scheme 的 StoreKit Configuration）。真机请用 Sandbox 账号验收购买、恢复与过期。

## Development schema 初始化

1. 使用带 iCloud entitlement 的 Debug 签名在真机或已登录 iCloud 的模拟器运行。
2. 仅在 Debug 构建中添加启动参数 `-InitializeCloudKitSchema`。
3. 启动后会幂等写入 `schema-initialization:v2` 标记，为每种同步实体保留一条零值记录。普通学习快照会忽略这些未知内容 ID。
4. 在 CloudKit Console 的 Development 环境确认以下 record type 和字段完整：
   - `CD_LessonProgressRecord`
   - `CD_LearningEventRecord`
   - `CD_ReviewLogRecord`
   - `CD_CardPreferenceRecord`
   - `CD_ProfilePreferenceRecord`
5. 移除启动参数并完成双设备 Development 同步验收。

## Production 部署

在 CloudKit Console 使用 Deploy Schema Changes 将已验证的 Development schema 部署到 Production。发布构建不会执行初始化工具，且 App 不会尝试从客户端修改 Production schema。

注意：

- CloudKit 同步是最终一致的。未登录 iCloud、账号受限或暂时不可用时，应用继续使用本地 SwiftData 数据，并在个人页显示“仅本机”。
- 用户关闭云同步后，设置会在下次启动生效。应用仍使用名为 `CloudSync` 的本地 store，不删除本机或云端数据；重新开启并重启后恢复与同一个 Private CloudKit 数据库的合并。
