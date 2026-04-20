@Entry
@Component
struct WhackAMole {
  // 游戏配置（显式声明类型）
  private readonly rows: number = 3;
  private readonly cols: number = 3;
  private readonly gameTime: number = 30;
  private readonly moleShowTime: number = 1000;

  // 游戏状态（显式声明类型）
  @State score: number = 0;
  @State timeLeft: number = this.gameTime;
  @State isPlaying: boolean = false;
  @State moleIndex: number = -1;
  @State hitEffectIndex: number = -1;

  // 定时器（显式声明number | null）
  private gameTimer: number | null = null;
  private moleTimer: number | null = null;

  // 生成地鼠洞数组（ArkTS兼容写法，完全显式类型）
  private getHoleArray(): number[] {
    const holes: number[] = [];
    const total: number = this.rows * this.cols;
    for (let i: number = 0; i < total; i++) {
      holes.push(i);
    }
    return holes;
  }

  // 开始游戏（显式返回void）
  startGame(): void {
    this.score = 0;
    this.timeLeft = this.gameTime;
    this.isPlaying = true;
    this.moleIndex = -1;
    this.hitEffectIndex = -1;

    // 倒计时定时器
    this.gameTimer = setInterval((): void => {
      if (this.timeLeft > 0) {
        this.timeLeft -= 1;
      } else {
        this.endGame();
      }
    }, 1000);

    // 启动地鼠刷新
    this.showMole();
  }

  // 结束游戏（显式返回void）
  endGame(): void {
    this.isPlaying = false;
    if (this.gameTimer !== null) {
      clearInterval(this.gameTimer);
      this.gameTimer = null;
    }
    if (this.moleTimer !== null) {
      clearTimeout(this.moleTimer);
      this.moleTimer = null;
    }
    this.moleIndex = -1;
  }

  // 随机显示地鼠（显式返回void）
  showMole(): void {
    if (!this.isPlaying) return;

    const totalHoles: number = this.rows * this.cols;
    // 显式声明随机数类型
    const randomIndex: number = Math.floor(Math.random() * totalHoles);
    this.moleIndex = randomIndex;
    this.hitEffectIndex = -1;

    // 地鼠消失定时器
    this.moleTimer = setTimeout((): void => {
      this.moleIndex = -1;
      // 延迟后刷新下一只
      setTimeout((): void => {
        this.showMole();
      }, 300);
    }, this.moleShowTime);
  }

  // 击打地鼠（显式参数和返回值类型）
  hitMole(index: number): void {
    if (!this.isPlaying || index !== this.moleIndex) return;

    this.score += 10;
    this.hitEffectIndex = index;
    this.moleIndex = -1;

    // 清除当前定时器，立即刷新下一只
    if (this.moleTimer !== null) {
      clearTimeout(this.moleTimer);
      this.moleTimer = null;
    }
    setTimeout((): void => {
      this.showMole();
    }, 300);
  }

  build() {
    Column() {
      // 顶部信息栏
      Row() {
        Text(`得分: ${this.score}`)
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .margin({ right: 30 })

        Text(`剩余时间: ${this.timeLeft}s`)
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .margin({ right: 30 })

        Button(this.isPlaying ? "游戏中..." : "开始游戏")
          .onClick((): void => {
            if (!this.isPlaying) {
              this.startGame();
            }
          })
          .enabled(!this.isPlaying)
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .padding(20)

      // 游戏结束提示
      if (!this.isPlaying && this.timeLeft !== this.gameTime) {
        Text(`游戏结束！最终得分: ${this.score}`)
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.Red)
          .margin(20)
      }

      // 游戏区域（地鼠洞网格）
      Grid() {
        // ForEach使用显式类型的数组，完全符合ArkTS规范
        ForEach(this.getHoleArray(), (index: number) => {
          GridItem() {
            Stack() {
              // 地鼠洞背景
              Circle()
                .width('100%')
                .height('100%')
                .fill('#8B4513')

              // 地鼠
              if (index === this.moleIndex) {
                Text('🐹')
                  .fontSize(50)
                  .scale({ x: 1.2, y: 1.2 })
                  .animation({
                    duration: 200,
                    curve: Curve.EaseOut
                  })
              }

              // 击中效果
              if (index === this.hitEffectIndex) {
                Text('💥')
                  .fontSize(50)
              }
            }
            .width('100%')
            .height('100%')
            .onClick((): void => {
              this.hitMole(index);
            })
          }
        }, (index: number): string => {
          // ForEach必须加第三个参数：唯一键生成器
          return index.toString();
        })
      }
      .columnsTemplate('1fr 1fr 1fr')
      .rowsTemplate('1fr 1fr 1fr')
      .width('90%')
      .aspectRatio(1)
      .padding(10)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5DC')
  }
}