using UnityEngine;
using System.Collections;
using System.Threading.Tasks;
using System.Runtime.InteropServices;
using AOT;

namespace Stopiccot {

	public class ImagePicker {

		#if UNITY_IOS && !UNITY_EDITOR
		protected delegate void IOSTakePhotoCallback(string path);

		[DllImport("__Internal")]
		private static extern void Stopiccot_ImagePicker_TakePhoto(IOSTakePhotoCallback callback, bool allowEditing);

		[DllImport("__Internal")]
		private static extern void Stopiccot_ImagePicker_SelectPhoto(IOSTakePhotoCallback callback, bool allowEditing);

		[MonoPInvokeCallback(typeof(IOSTakePhotoCallback))]
		protected static void Callback(string path) {
			completionSource.SetResult(path);
		}
		#endif

		#if UNITY_ANDROID && !UNITY_EDITOR
		public class AndroidTakePhotoCallback : AndroidJavaProxy
		{
			protected TaskCompletionSource<string> completionSource = null;

			public AndroidTakePhotoCallback(TaskCompletionSource<string> completionSource) : base("com.imagepicker.ImagePickerModule$Callback") {
				this.completionSource = completionSource;
			}

			public void actuallyCall(string path)
			{
				Debug.Log("-----------");
				Debug.Log(path);
				Debug.Log("-----------");
				completionSource.SetResult(path);
			}
		}
		#endif

		protected static TaskCompletionSource<string> completionSource = null;

		public static Task<string> TakePhoto(bool allowsEditing = false) {
			completionSource = new TaskCompletionSource<string>();
			#if UNITY_IOS && !UNITY_EDITOR
			Stopiccot_ImagePicker_TakePhoto(Callback, allowsEditing);
			#elif UNITY_ANDROID && !UNITY_EDITOR
			using (AndroidJavaObject imagePickerClass = new AndroidJavaClass("com.imagepicker.ImagePickerModule")) {
			using (AndroidJavaClass unityPlayer = new AndroidJavaClass("com.unity3d.player.UnityPlayer")) {
				var currentActivityObject = unityPlayer.GetStatic<AndroidJavaObject>("currentActivity");
				var imagePickerInstance = imagePickerClass.CallStatic<AndroidJavaObject>("getInstance");
				imagePickerInstance.Call("setCurrentActivity", currentActivityObject);
				imagePickerInstance.Call("launchCamera", new AndroidTakePhotoCallback(completionSource));
			}
			}
			#else
			completionSource.SetResult(UnityEditor.EditorUtility.OpenFilePanel("Select image", "", "png,jpg,jpeg"));
			#endif

			return completionSource.Task;
		}

		public static Task<string> SelectPhoto(bool allowsEditing = false) {
			completionSource = new TaskCompletionSource<string>();
			#if UNITY_IOS && !UNITY_EDITOR
			Stopiccot_ImagePicker_SelectPhoto(Callback, allowsEditing);
			#elif UNITY_ANDROID && !UNITY_EDITOR
			//...
			#else
			completionSource.SetResult(UnityEditor.EditorUtility.OpenFilePanel("Select image", "", "png,jpg,jpeg"));
			#endif

			return completionSource.Task;
		}
	}
}
