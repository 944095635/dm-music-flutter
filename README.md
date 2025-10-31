# DM Music

## Flutter 开发的音乐App程序

|黑色主题|
| -------- | 
|<img src="https://raw.githubusercontent.com/944095635/dm-music-flutter/master/preview/image1.png" >|


|白色主题|
| -------- | 
|<img src="https://raw.githubusercontent.com/944095635/dm-music-flutter/master/preview/image1.png" >|



|黑色主题|
| -------- | 
|<img src="https://raw.githubusercontent.com/944095635/dm-music-flutter/master/preview/dark.jpeg" >|


|白色主题|
| -------- | 
|<img src="https://raw.githubusercontent.com/944095635/dm-music-flutter/master/preview/light.jpeg" >|

### 下面 颜色定义参考 - 来自互联网

Primary 和 Secondary 颜色：这些颜色通常用于应用程序的主要元素，如按钮、工具栏和突出显示的部分。

在Material Design 中，通常有一个主要颜色（primary）和一个辅助颜色（secondary）。

Tertiary 颜色：这些颜色通常用于应用程序的次要元素，如次要按钮或标签。

Error 颜色：这是用于表示错误状态的颜色。通常用于验证错误或应用程序中的问题指示。

Background 和 Surface 颜色：这些颜色用于应用程序的背景和表面元素，如卡片、面板和其他背景元素。

Inverse 颜色：这些颜色通常用于反向文本，即浅色文本放在深色背景上，或深色文本放在浅色背景上。

Shadow 颜色：这些颜色用于模拟元素的阴影。

Outline 颜色：这些颜色通常用于边框或轮廓。

Scrim 颜色：这些颜色用于创建遮罩效果，通常在对话框或抽屉背后使用。

primary: 主要颜色，用于应用的主要界面元素。

primary: Color = ColorLightTokens.Primary
onPrimary: 主要颜色上的文本或图标颜色，确保对比度足够高以便可读。

onPrimary: Color = ColorLightTokens.OnPrimary
primaryContainer: 主要颜色的容器颜色，通常用于按钮或卡片的背景色。

primaryContainer: Color = ColorLightTokens.PrimaryContainer
onPrimaryContainer: 主要颜色容器上的文本或图标颜色。

onPrimaryContainer: Color = ColorLightTokens.OnPrimaryContainer
inversePrimary: 主要颜色的反转版，通常用于深色模式下的主要颜色。

inversePrimary: Color = ColorLightTokens.InversePrimary
secondary: 次要颜色，用于次要界面元素。

secondary: Color = ColorLightTokens.Secondary
onSecondary: 次要颜色上的文本或图标颜色。

onSecondary: Color = ColorLightTokens.OnSecondary
secondaryContainer: 次要颜色的容器颜色。

secondaryContainer: Color = ColorLightTokens.SecondaryContainer
onSecondaryContainer: 次要颜色容器上的文本或图标颜色。

onSecondaryContainer: Color = ColorLightTokens.OnSecondaryContainer
tertiary: 第三级颜色，用于辅助界面元素。

tertiary: Color = ColorLightTokens.Tertiary
onTertiary: 第三级颜色上的文本或图标颜色。

onTertiary: Color = ColorLightTokens.OnTertiary
tertiaryContainer: 第三级颜色的容器颜色。

tertiaryContainer: Color = ColorLightTokens.TertiaryContainer
onTertiaryContainer: 第三级颜色容器上的文本或图标颜色。

onTertiaryContainer: Color = ColorLightTokens.OnTertiaryContainer
background: 应用的背景颜色。

background: Color = ColorLightTokens.Background
onBackground: 背景上的文本或图标颜色。

onBackground: Color = ColorLightTokens.OnBackground
surface: 表面的颜色，用于卡片、对话框等的背景色。

surface: Color = ColorLightTokens.Surface
onSurface: 表面上的文本或图标颜色。

onSurface: Color = ColorLightTokens.OnSurface
surfaceVariant: 表面的变体颜色。

surfaceVariant: Color = ColorLightTokens.SurfaceVariant
onSurfaceVariant: 表面变体上的文本或图标颜色。

onSurfaceVariant: Color = ColorLightTokens.OnSurfaceVariant
surfaceTint: 用于给表面涂色的颜色，通常与主要颜色一致。

surfaceTint: Color = primary
inverseSurface: 表面的反转版颜色，通常用于深色模式下的表面颜色。

inverseSurface: Color = ColorLightTokens.InverseSurface
inverseOnSurface: 反转表面上的文本或图标颜色。

inverseOnSurface: Color = ColorLightTokens.InverseOnSurface
error: 错误状态下使用的颜色。

error: Color = ColorLightTokens.Error
onError: 错误状态下的文本或图标颜色。

onError: Color = ColorLightTokens.OnError
errorContainer: 错误状态的容器颜色。

errorContainer: Color = ColorLightTokens.ErrorContainer
onErrorContainer: 错误状态容器上的文本或图标颜色。

onErrorContainer: Color = ColorLightTokens.OnErrorContainer
outline: 用于边框或分隔线的颜色。

outline: Color = ColorLightTokens.Outline
outlineVariant: 边框或分隔线的变体颜色。

outlineVariant: Color = ColorLightTokens.OutlineVariant
scrim: 用于遮罩的颜色，通常用于模态对话框后面的背景。

scrim: Color = ColorLightTokens.Scrim
surfaceBright: 明亮的表面颜色。

surfaceBright: Color = ColorLightTokens.SurfaceBright
surfaceContainer: 容器的表面颜色。

surfaceContainer: Color = ColorLightTokens.SurfaceContainer
surfaceContainerHigh: 高亮的容器表面颜色。

surfaceContainerHigh: Color = ColorLightTokens.SurfaceContainerHigh
surfaceContainerHighest: 最高亮的容器表面颜色。

surfaceContainerHighest: Color = ColorLightTokens.SurfaceContainerHighest
surfaceContainerLow: 低亮的容器表面颜色。

surfaceContainerLow: Color = ColorLightTokens.SurfaceContainerLow
surfaceContainerLowest: 最低亮的容器表面颜色。

surfaceContainerLowest: Color = ColorLightTokens.SurfaceContainerLowest
surfaceDim: 昏暗的表面颜色。

surfaceDim: Color = ColorLightTokens.SurfaceDim











IconButton(
                    onPressed: () {
                      if (Get.isDarkMode) {
                        Get.changeThemeMode(ThemeMode.light);
                      } else {
                        Get.changeThemeMode(ThemeMode.dark);
                      }
                    },
                    icon: SvgPicxture.asset(
                      AssetsSvgs.musicRepeatSvg,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
