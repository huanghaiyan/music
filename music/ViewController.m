#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()<AVAudioPlayerDelegate>{
    AVAudioPlayer   * _audioPlayer;      //播放器
    UISlider        * _timeSlider;      //进度调节滑块
    UISlider        * _volumeSlider;    //音量调节滑块
    UIButton        * _beginBtn;        //开始按钮
    UIButton        * _stopBtn;         //停止按钮
    UIImageView     * _recordImageView; //播放时旋转的图片
    __block CGFloat _angle;             //记录图片旋转角度
}

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    _angle = 0.0f;
    /*滑块功能提示*/
    for (int i = 0; i < 2; i++) {
        UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(20,80+70*i,30,20)];
        label.textColor = [UIColor lightGrayColor];
        label.text = @[@"进度",@"音量"][i];
        label.font = [UIFont systemFontOfSize:12];
        [label sizeToFit];
        [self.view addSubview:label];
    }
    /*进度调节滑块*/
    _timeSlider = [[UISlider alloc] init];
    _timeSlider.frame = CGRectMake(20, 100, CGRectGetWidth(self.view.frame)-20*2, 30);
    _timeSlider.tag = 200;
    _timeSlider.minimumTrackTintColor = [UIColor greenColor];
    [_timeSlider addTarget:self action:@selector(sliderClick:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_timeSlider];
    
    /*音量调节滑块*/
    _volumeSlider = [[UISlider alloc] init];
    _volumeSlider.frame = CGRectMake(CGRectGetMinX(_timeSlider.frame), CGRectGetMaxY(_timeSlider.frame)+40, CGRectGetWidth(_timeSlider.frame), 30);
    _volumeSlider.tag = 201;
    _volumeSlider.minimumValue = 0.0f;
    _volumeSlider.maximumValue = 100.0f;
    [_volumeSlider addTarget:self action:@selector(sliderClick:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_volumeSlider];
    
    /*开始、停止播放按钮*/
    for (int i = 0; i < 2; i++) {
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(CGRectGetMinX(_volumeSlider.frame)+CGRectGetWidth(_volumeSlider.frame)/2*i, CGRectGetMaxY(_volumeSlider.frame)+40, (CGRectGetWidth(self.view.frame)-20*2)/2, 40);
        button.tag = 100+i;
        [button setTitle:@[@"开始",@"停止"][i] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setBackgroundColor:@[[UIColor blueColor],[UIColor redColor]][i]];
        [self.view addSubview:button];
    }
    _beginBtn = (UIButton *)[self.view viewWithTag:100];
    _stopBtn = (UIButton *)[self.view viewWithTag:101];
    
    /*播放时旋转的图片*/
    _recordImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"record"] ];
    [_recordImageView sizeToFit];
    _recordImageView.center = CGPointMake(CGRectGetMidX(self.view.frame),CGRectGetMaxY(self.view.frame)-100);
    [self.view addSubview:_recordImageView];
    
    /*根据播放器播放进度更新进度滑块位置*/
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeTick) userInfo:nil repeats:YES];
    
    /*需加载mp3的文件路径*/
   // NSString *path = [NSString stringWithFormat:@"%@/123.mp3",[[NSBundle mainBundle] resourcePath]];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"27836541" ofType:@"mp3"];
    NSURL *url = [NSURL fileURLWithPath:path];
    
    //开始写代码，创建一个音乐播放器，完成播放功能及相应设置，其中设置默认音量为5。
    _audioPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:url error:nil];
    
    _audioPlayer.delegate = self;
    _audioPlayer.volume = 5;
    
    [_audioPlayer prepareToPlay];

}

- (void)timeTick{
    
    //开始写代码，实现定时器的执行方法，根据播放器播放进度更新进度滑块位置
    _timeSlider.value = _audioPlayer.currentTime/_audioPlayer.duration;
}


/*按钮点击事件*/
- (void)btnClick:(UIButton *)btn{
    //开始写代码，实现按钮点击事件，在正确的位置实现播放器播放、暂停和停止功能
    if(btn.tag == 100){
        if(_audioPlayer.isPlaying){
            [self endAnimation];
            [btn setTitle:@"继续" forState:UIControlStateNormal];
            
            [_audioPlayer stop];
            
        }else{
            [self startAnimation];
            [btn setTitle:@"暂停" forState:UIControlStateNormal];
            
            [_audioPlayer play];
            
        }
    }else if(btn.tag == 101){
        [self endAnimation];
        [_beginBtn setTitle:@"开始" forState:UIControlStateNormal];
        _recordImageView.transform = CGAffineTransformIdentity;
        
        [_audioPlayer stop];
        
        
    }
}

/*播放时旋转图片的方法*/
- (void)startAnimation{
    CGAffineTransform endAngle = CGAffineTransformMakeRotation((int)_angle%360 * (M_PI / 180.0f));
    
    [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        _recordImageView.transform = endAngle;
    } completion:^(BOOL finished) {
        if (finished) {
            _angle += 5;
            [self startAnimation];
        }
    }];
    
}
/*结束旋转的方法*/
- (void)endAnimation{
    [_recordImageView.layer removeAllAnimations];
}


- (void)sliderClick:(UISlider *)slider{

    //开始写代码，完成滑块的响应事件（分别调节播放进度和调节音量功能）
    if(slider.tag == 200){
        _timeSlider.value = _audioPlayer.currentTime/_audioPlayer.duration;
    }
    
    else if(slider.tag == 201){
            _audioPlayer.volume = slider.value;
    }
}

#pragma mark - AVAudioPlayerDelegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    [_beginBtn setTitle:@"开始" forState:UIControlStateNormal];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end