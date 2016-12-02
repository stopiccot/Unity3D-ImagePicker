using UnityEngine;
using System.Collections;
using System.Threading.Tasks;
using System.Runtime.InteropServices;
using AOT;

namespace Stopiccot {

	public class NativeGallery {

		protected delegate void TakePhotoCallback(string path);

		#if UNITY_IOS && !UNITY_EDITOR
		[DllImport("__Internal")]
		private static extern void Stopiccot_NativeGallery_TakePhoto(TakePhotoCallback callback, bool allowEditing);

		[DllImport("__Internal")]
		private static extern void Stopiccot_NativeGallery_SelectPhoto(TakePhotoCallback callback, bool allowEditing);
		#endif

		protected static TaskCompletionSource<string> completionSource = null;

		public static Task<string> TakePhoto(bool allowsEditing = false) {
			completionSource = new TaskCompletionSource<string>();
			#if UNITY_IOS && !UNITY_EDITOR
			Stopiccot_NativeGallery_TakePhoto(Callback, allowsEditing);
			return completionSource.Task;
			#else
			completionSource.SetResult(null);
			return completionSource.Task;
			#endif
		}

		public static Task<string> SelectPhoto(bool allowsEditing = false) {
			completionSource = new TaskCompletionSource<string>();
			#if UNITY_IOS && !UNITY_EDITOR
			Stopiccot_NativeGallery_SelectPhoto(Callback, allowsEditing);
			return completionSource.Task;
			#else
			completionSource.SetResult(null);
			return completionSource.Task;
			#endif
		}

		[MonoPInvokeCallback(typeof(TakePhotoCallback))]
		protected static void Callback(string path) {
			completionSource.SetResult(path);
		}
	}
}
