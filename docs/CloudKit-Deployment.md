# LearnNow CloudKit 部署

LearnNow 使用 Private CloudKit 数据库 `iCloud.fanxi.LearnNow`。课程内容不上传 CloudKit；个人进度、XP 事件、复习日志与卡片偏好由 SwiftData 自动同步，FSRS 当前状态缓存只保存在设备本地。

## Development schema 初始化

1. 使用带 iCloud entitlement 的 Debug 签名在真机或已登录 iCloud 的模拟器运行。
2. 仅在 Debug 构建中添加启动参数 `-InitializeCloudKitSchema`。
3. 启动后会幂等写入 `schema-initialization:v1` 标记，为每种同步实体保留一条零值记录。普通学习快照会忽略这些未知内容 ID。
4. 在 CloudKit Console 的 Development 环境确认以下 record type 和字段完整：
   - `CD_LessonProgressRecord`
   - `CD_LearningEventRecord`
   - `CD_ReviewLogRecord`
   - `CD_CardPreferenceRecord`
5. 移除启动参数并完成双设备 Development 同步验收。

## Production 部署

在 CloudKit Console 使用 Deploy Schema Changes 将已验证的 Development schema 部署到 Production。发布构建不会执行初始化工具，且 App 不会尝试从客户端修改 Production schema。

注意：CloudKit 同步是最终一致的。未登录 iCloud、账号受限或暂时不可用时，应用继续使用本地 SwiftData 数据，并在个人页显示“仅本机”。
