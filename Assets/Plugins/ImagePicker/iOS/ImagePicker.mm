#import <UIKit/UIKit.h>

typedef void (*IOSTakePhotoCallback)(const char* path);

extern UIViewController *UnityGetGLViewController();

@interface ImagePickerUIViewController: UIViewController<UINavigationControllerDelegate, UIImagePickerControllerDelegate> {
@public
    IOSTakePhotoCallback takePhotoCallback;
    UIImagePickerController *imagePickerController;
}
@end


@implementation ImagePickerUIViewController

- (id)init {
    self = [super init];
    
    if (self) {
        imagePickerController = [[UIImagePickerController alloc] init];
    }

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self showImagePicker];
}

- (void)showImagePicker {
    imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
    imagePickerController.delegate = self;
    
    [self.view addSubview:imagePickerController.view];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    image = [self fixOrientation:image];
    
    NSString *docDirPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* filePath = [[[docDirPath stringByAppendingString:@"/"] stringByAppendingString:[[NSUUID UUID] UUIDString]] stringByAppendingString:@".jpg"];
    
    NSLog(@"filePath: \"%@\"", filePath);
    
    NSData* imageData = UIImageJPEGRepresentation(image, 1.0f);
    [imageData writeToFile:filePath atomically:YES];

    [self dismissViewControllerAnimated:YES completion:nil];
    
    takePhotoCallback([filePath UTF8String]);
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (UIImage *)fixOrientation:(UIImage *)srcImg {
    if (srcImg.imageOrientation == UIImageOrientationUp) {
        return srcImg;
    }
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    switch (srcImg.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, srcImg.size.width, srcImg.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, srcImg.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, srcImg.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (srcImg.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, srcImg.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, srcImg.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    CGContextRef ctx = CGBitmapContextCreate(NULL, srcImg.size.width, srcImg.size.height, CGImageGetBitsPerComponent(srcImg.CGImage), 0, CGImageGetColorSpace(srcImg.CGImage), CGImageGetBitmapInfo(srcImg.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (srcImg.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            CGContextDrawImage(ctx, CGRectMake(0,0,srcImg.size.height,srcImg.size.width), srcImg.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,srcImg.size.width,srcImg.size.height), srcImg.CGImage);
            break;
    }
    
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

@end

extern "C" void Stopiccot_ImagePicker_TakePhoto(IOSTakePhotoCallback callback, bool allowsEditing) {
    ImagePickerUIViewController* imagePickerController = [[ImagePickerUIViewController alloc] init];
    imagePickerController->takePhotoCallback = callback;
    imagePickerController->imagePickerController.allowsEditing = allowsEditing;
    imagePickerController->imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    [UnityGetGLViewController() presentViewController:imagePickerController animated:true completion:nil];
}

extern "C" void Stopiccot_ImagePicker_SelectPhoto(IOSTakePhotoCallback callback, bool allowsEditing) {
    ImagePickerUIViewController* imagePickerController = [[ImagePickerUIViewController alloc] init];
    imagePickerController->takePhotoCallback = callback;
    imagePickerController->imagePickerController.allowsEditing = allowsEditing;
    imagePickerController->imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [UnityGetGLViewController() presentViewController:imagePickerController animated:true completion:nil];
}
