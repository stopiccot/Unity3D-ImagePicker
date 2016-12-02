#import <UIKit/UIKit.h>

extern UIViewController *UnityGetGLViewController();

typedef void (*TakePhotoCallback)(const char* path);
TakePhotoCallback takePhotoCallback;
bool allowEditing;

@interface NativeGalleryUIViewController: UIViewController<UINavigationControllerDelegate, UIImagePickerControllerDelegate> {
@public
    UIImagePickerController *imagePickerController;
}
@end


@implementation NativeGalleryUIViewController

- (id)init {
    self = [super init];
    
    if (self) {
        imagePickerController = [[UIImagePickerController alloc] init];
    }

    return self;
}

- (void)viewDidLoad {
    NSLog(@"viewDidLoad");
    [super viewDidLoad];
    
    [self showImagePicker];
}


- (void)showImagePicker {
    imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
    imagePickerController.delegate = self;
    
    [self.view addSubview:imagePickerController.view];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *originalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    NSString *docDirPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* filePath = [[[docDirPath stringByAppendingString:@"/"] stringByAppendingString:[[NSUUID UUID] UUIDString]] stringByAppendingString:@".jpg"];
    
    NSLog(@"filePath: \"%@\"", filePath);
    
    NSData* imageData = UIImageJPEGRepresentation(originalImage, 1.0f);
    [imageData writeToFile:filePath atomically:YES];

    [self dismissViewControllerAnimated:YES completion:nil];
    
    takePhotoCallback([filePath UTF8String]);
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end

extern "C" void Stopiccot_NativeGallery_TakePhoto(TakePhotoCallback callback, bool allowsEditing) {
    takePhotoCallback = callback;
    
    NSLog(@"Before constructor");
    NativeGalleryUIViewController* nativeGalleryController = [[NativeGalleryUIViewController alloc] init];
    nativeGalleryController->imagePickerController.allowsEditing = allowsEditing;
    nativeGalleryController->imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    NSLog(@"After constructor");
    [UnityGetGLViewController() presentViewController:nativeGalleryController animated:true completion:nil];
}

extern "C" void Stopiccot_NativeGallery_SelectPhoto(TakePhotoCallback callback, bool allowsEditing) {
    takePhotoCallback = callback;
    
    NSLog(@"Before constructor");
    NativeGalleryUIViewController* nativeGalleryController = [[NativeGalleryUIViewController alloc] init];
    nativeGalleryController->imagePickerController.allowsEditing = allowsEditing;
    nativeGalleryController->imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    NSLog(@"After constructor");
    [UnityGetGLViewController() presentViewController:nativeGalleryController animated:true completion:nil];
}
