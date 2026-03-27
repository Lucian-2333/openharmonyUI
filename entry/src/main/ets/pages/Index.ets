// 智能设备数据模型
interface DeviceInfo {
  id: number
  name: string
  icon: Resource
  isOn: boolean
  type: 'light' | 'ac' | 'speaker' | 'curtain'
  value: number // 亮度/温度/音量/开合度
  room: string
}

@Component
struct DeviceCard {
  @ObjectLink device: DeviceItemData
  onToggle: () => void = () => {}
  onValueChange: (val: number) => void = () => {}
  @State private scaleVal: number = 1
  @State private isPressed: boolean = false

  getIconText(): string {
    if (this.device.type === 'light') return '💡'
    if (this.device.type === 'ac') return '❄️'
    if (this.device.type === 'speaker') return '🔊'
    return '🪟'
  }

  getValueLabel(): string {
    if (this.device.type === 'light') return `亮度 ${this.device.value}%`
    if (this.device.type === 'ac') return `${this.device.value}°C`
    if (this.device.type === 'speaker') return `音量 ${this.device.value}%`
    return `开合 ${this.device.value}%`
  }

  getAccentColor(): string {
    if (!this.device.isOn) return '#9E9E9E'
    if (this.device.type === 'light') return '#FFB300'
    if (this.device.type === 'ac') return '#29B6F6'
    if (this.device.type === 'speaker') return '#66BB6A'
    return '#AB47BC'
  }

  build() {
    Column() {
      // 顶部：图标 + 开关
      Row() {
        // 设备图标圆形背景
        Stack() {
          Circle()
            .width(48)
            .height(48)
            .fill(this.device.isOn ? this.getAccentColor() : '#E0E0E0')
            .opacity(this.device.isOn ? 0.2 : 0.5)
          Text(this.getIconText())
            .fontSize(24)
        }
        .width(48)
        .height(48)

        Blank()

        Toggle({ type: ToggleType.Switch, isOn: this.device.isOn })
          .selectedColor(this.getAccentColor())
          .onChange((isOn: boolean) => {
            this.onToggle()
          })
          .width(48)
          .height(26)
      }
      .width('100%')

      // 设备名称
      Text(this.device.name)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.device.isOn ? '#212121' : '#9E9E9E')
        .margin({ top: 12 })
        .alignSelf(ItemAlign.Start)

      // 房间
      Text(this.device.room)
        .fontSize(12)
        .fontColor('#BDBDBD')
        .margin({ top: 2 })
        .alignSelf(ItemAlign.Start)

      Blank()

      // 数值显示
      if (this.device.isOn) {
        Text(this.getValueLabel())
          .fontSize(13)
          .fontColor(this.getAccentColor())
          .fontWeight(FontWeight.Medium)
          .margin({ bottom: 8 })
          .alignSelf(ItemAlign.Start)
          .transition({ type: TransitionType.Insert, opacity: 0 })

        // 滑动条
        Slider({
          value: this.device.value,
          min: this.device.type === 'ac' ? 16 : 0,
          max: this.device.type === 'ac' ? 30 : 100,
          style: SliderStyle.InSet
        })
          .blockColor(this.getAccentColor())
          .trackColor('#E0E0E0')
          .selectedColor(this.getAccentColor())
          .onChange((value: number) => {
            this.onValueChange(value)
          })
          .width('100%')
          .transition({ type: TransitionType.Insert, opacity: 0 })
      }
    }
    .width('100%')
    .height(this.device.isOn ? 200 : 140)
    .padding(16)
    .backgroundColor(this.device.isOn ? '#FFFFFF' : '#F5F5F5')
    .borderRadius(20)
    .shadow({
      radius: this.device.isOn ? 12 : 4,
      color: this.device.isOn ? this.getAccentColor() + '30' : '#00000010',
      offsetX: 0,
      offsetY: this.device.isOn ? 4 : 2
    })
    .scale({ x: this.scaleVal, y: this.scaleVal })
    .animation({ duration: 250, curve: Curve.EaseInOut })
    .onTouch((event: TouchEvent) => {
      if (event.type === TouchType.Down) {
        this.scaleVal = 0.95
        this.isPressed = true
      } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
        this.scaleVal = 1
        this.isPressed = false
      }
    })
  }
}

// 场景模式数据
interface SceneMode {
  name: string
  icon: string
  color: string
  isActive: boolean
}

@Observed
class DeviceItemData {
  id: number = 0
  name: string = ''
  icon: string = ''
  isOn: boolean = false
  type: 'light' | 'ac' | 'speaker' | 'curtain' = 'light'
  value: number = 0
  room: string = ''

  constructor(id: number, name: string, type: 'light' | 'ac' | 'speaker' | 'curtain',
    isOn: boolean, value: number, room: string) {
    this.id = id
    this.name = name
    this.type = type
    this.isOn = isOn
    this.value = value
    this.room = room
  }
}

@Observed
class SceneModeData {
  name: string
  icon: string
  color: string
  isActive: boolean

  constructor(name: string, icon: string, color: string, isActive: boolean) {
    this.name = name
    this.icon = icon
    this.color = color
    this.isActive = isActive
  }
}

@Entry
@Component
struct Index {
  @State devices: DeviceItemData[] = [
    new DeviceItemData(1, '客厅主灯', 'light', true, 75, '客厅'),
    new DeviceItemData(2, '空调', 'ac', true, 24, '卧室'),
    new DeviceItemData(3, '智能音箱', 'speaker', false, 50, '书房'),
    new DeviceItemData(4, '窗帘', 'curtain', false, 0, '客厅'),
    new DeviceItemData(5, '床头灯', 'light', true, 40, '卧室'),
    new DeviceItemData(6, '新风系统', 'ac', false, 22, '全屋'),
  ]

  @State scenes: SceneModeData[] = [
    new SceneModeData('回家模式', '🏠', '#FF7043', true),
    new SceneModeData('睡眠模式', '🌙', '#5C6BC0', false),
    new SceneModeData('影院模式', '🎬', '#AB47BC', false),
    new SceneModeData('离家模式', '👋', '#78909C', false),
  ]

  @State currentTemp: string = '26°C'
  @State currentHumidity: string = '65%'
  @State greeting: string = ''

  aboutToAppear() {
    const hour = new Date().getHours()
    if (hour < 6) this.greeting = '夜深了'
    else if (hour < 12) this.greeting = '早上好'
    else if (hour < 18) this.greeting = '下午好'
    else this.greeting = '晚上好'
  }

  getOnlineCount(): number {
    return this.devices.filter(d => d.isOn).length
  }

  build() {
    Column() {
      // ===== 顶部状态栏 =====
      Row() {
        Column() {
          Text(this.greeting)
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .fontColor('#212121')
          Text(`${this.getOnlineCount()} 个设备运行中`)
            .fontSize(14)
            .fontColor('#9E9E9E')
            .margin({ top: 4 })
        }
        .alignItems(HorizontalAlign.Start)

        Blank()

        // 环境信息胶囊
        Row() {
          Text(`🌡 ${this.currentTemp}`)
            .fontSize(13)
            .fontColor('#616161')
          Divider()
            .vertical(true)
            .height(14)
            .margin({ left: 8, right: 8 })
            .color('#E0E0E0')
          Text(`💧 ${this.currentHumidity}`)
            .fontSize(13)
            .fontColor('#616161')
        }
        .padding({ left: 12, right: 12, top: 6, bottom: 6 })
        .backgroundColor('#F5F5F5')
        .borderRadius(20)
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 12 })

      // ===== 场景模式 =====
      Text('场景模式')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#212121')
        .margin({ top: 24, bottom: 12 })
        .padding({ left: 20 })
        .alignSelf(ItemAlign.Start)

      Scroll() {
        Row({ space: 12 }) {
          ForEach(this.scenes, (scene: SceneModeData, index: number) => {
            Column() {
              Text(scene.icon)
                .fontSize(28)
              Text(scene.name)
                .fontSize(12)
                .fontColor(scene.isActive ? '#FFFFFF' : '#616161')
                .margin({ top: 6 })
            }
            .width(80)
            .height(80)
            .justifyContent(FlexAlign.Center)
            .backgroundColor(scene.isActive ? scene.color : '#F5F5F5')
            .borderRadius(16)
            .shadow({
              radius: scene.isActive ? 8 : 0,
              color: scene.isActive ? scene.color + '40' : '#00000000',
              offsetX: 0,
              offsetY: scene.isActive ? 3 : 0
            })
            .animation({ duration: 300, curve: Curve.EaseInOut })
            .onClick(() => {
              this.scenes.forEach((s, i) => {
                s.isActive = (i === index)
              })
              // 场景联动：根据选中场景切换设备状态
              if (scene.name === '睡眠模式') {
                this.devices.forEach(d => {
                  if (d.type === 'light') {
                    d.isOn = false
                  }
                  if (d.name === '床头灯') {
                    d.isOn = true
                    d.value = 10
                  }
                  if (d.type === 'ac') {
                    d.isOn = true
                    d.value = 22
                  }
                })
              } else if (scene.name === '回家模式') {
                this.devices.forEach(d => {
                  if (d.name === '客厅主灯') {
                    d.isOn = true
                    d.value = 75
                  }
                  if (d.type === 'ac') {
                    d.isOn = true
                  }
                })
              } else if (scene.name === '影院模式') {
                this.devices.forEach(d => {
                  if (d.type === 'light') {
                    d.isOn = true
                    d.value = 15
                  }
                  if (d.name === '窗帘') {
                    d.isOn = true
                    d.value = 100
                  }
                  if (d.name === '智能音箱') {
                    d.isOn = true
                    d.value = 70
                  }
                })
              } else if (scene.name === '离家模式') {
                this.devices.forEach(d => {
                  d.isOn = false
                })
              }
            })
          })
        }
        .padding({ left: 20, right: 20 })
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)

      // ===== 设备卡片网格 =====
      Text('我的设备')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#212121')
        .margin({ top: 24, bottom: 12 })
        .padding({ left: 20 })
        .alignSelf(ItemAlign.Start)

      // 设备网格
      Scroll() {
        Column({ space: 12 }) {
          // 两列网格布局
          ForEach(this.getDeviceRows(), (row: DeviceItemData[], rowIndex: number) => {
            Row({ space: 12 }) {
              ForEach(row, (device: DeviceItemData) => {
                DeviceCard({
                  device: device,
                  onToggle: () => {
                    device.isOn = !device.isOn
                  },
                  onValueChange: (val: number) => {
                    device.value = Math.round(val)
                  }
                })
                  .layoutWeight(1)
              })
              // 如果这行只有一个设备，补一个空白占位
              if (row.length === 1) {
                Column().layoutWeight(1)
              }
            }
            .width('100%')
          })
        }
        .padding({ left: 20, right: 20, bottom: 20 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FAFAFA')
  }

  getDeviceRows(): DeviceItemData[][] {
    let rows: DeviceItemData[][] = []
    for (let i = 0; i < this.devices.length; i += 2) {
      if (i + 1 < this.devices.length) {
        rows.push([this.devices[i], this.devices[i + 1]])
      } else {
        rows.push([this.devices[i]])
      }
    }
    return rows
  }
}
