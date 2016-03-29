//
//  ViewController.m
//  GameKit BlueTooth
//
//  Created by EMPty on 3/29/16.
//  Copyright (c) 2016 EMPty. All rights reserved.
//

#import "ViewController.h"
#import <GameKit/GameKit.h>


@interface ViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,GKPeerPickerControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (nonatomic,strong) GKSession* session;//会话
- (IBAction)connect:(id)sender;
- (IBAction)choose:(id)sender;
- (IBAction)send:(id)sender;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.image.contentMode = UIViewContentModeScaleAspectFit;
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];


}


//连接设备
- (IBAction)connect:(id)sender {
    //1.创建选择蓝牙设备的控制器
    GKPeerPickerController* ppc = [[GKPeerPickerController alloc]init];
    
    //2.成为该控制器的代理
    ppc.delegate = self;
    
    //3.显示蓝牙控制器
    [ppc show];
    
    
    
}

#pragma mark - GKPeerPickerControllerDelegate
//4.实现代理方法
//在代理方法中监控蓝牙的连接
/*
    picker 触发时间的控制器
    peerID 连接蓝牙设别的ID
    session 连接蓝牙的会话（可用通讯），只要拿到session，就可以传输数据
 
 */
- (void)peerPickerController:(GKPeerPickerController *)picker didConnectPeer:(NSString *)peerID toSession:(GKSession *)session
{
    NSLog(@"连接到设备：%@",peerID);
    //关闭蓝牙显示界面
    [picker dismiss];
    
    //设置接收到蓝牙数据后的监听器（非常古老，一般是通知或者代理）
    /*
        handler 谁来处理接受到的数据
        context 传递数据
     必须实现receiveData这个方法
     */
    [session setDataReceiveHandler:self withContext:nil];
     
     //保存session会话
     self.session = session;
    
     
}

#pragma mark - 句柄实现的方法
//接受到其他设备传递过来的数据，就会调用
//data 传递过来的数据
//peer 传递设备的ID
//session 会话
//context 注册监听时传递的参数
- (void) receiveData:(NSData *)data fromPeer:(NSString *)peer inSession: (GKSession *)session context:(void *)context
{
    NSLog(@"收到数据%@",data);
    UIImage* receivedImage = [UIImage imageWithData:data];
    self.image.image = receivedImage;
}

- (void)peerPickerControllerDidCancel:(GKPeerPickerController *)picker
    {
         NSLog(@"取消");
         
    }


//从相册选择照片
- (IBAction)choose:(id)sender {
    //1.创建图片选择控制器
    UIImagePickerController* imagePicker = [[UIImagePickerController alloc]init];
    
    
    //2.判断图库是否可用打开
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum])
    {
        NSLog(@"可用");
        //3.设置打开图库的类型
        imagePicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        //还需要添加UINavigationControllerDelegate
        imagePicker.delegate = self;
        
        //4.打开图片选择控制器
        [self presentViewController:imagePicker animated:YES completion:nil];
        
    }
    else{
        NSLog(@"不可用");
    }
    
    
    
}

- (IBAction)send:(id)sender {
    //利用session发送图片数据即可
    //1.取出image视图里的图片，转为二进制
    NSData* imageData = UIImagePNGRepresentation(self.image.image);
    //DataMode
    //GKSendDataReliable数据安全传输，慢  GKSendDataUnreliable数据不安全传输。快
    //error是否监听错误
    NSError* error = nil;
    [self.session sendDataToAllPeers:imageData withDataMode:GKSendDataReliable error:&error];
}

#pragma mark - imagePicker Delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSLog(@"%@",info);
    self.image.image = info[UIImagePickerControllerOriginalImage];
    //退出模态视图
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    NSLog(@"取消选择");
}

@end
