using UnityEditor.Callbacks;
using UnityEditor;
#if UNITY_IOS
using UnityEditor.iOS.Xcode;
#endif
using System.IO;

public class ImagePickerPostProcessBuild
{
	[PostProcessBuild]
	public static void OnPostProcessBuild(BuildTarget target, string path)
	{
		#if UNITY_IOS
		if (target != BuildTarget.iOS) {
			return;
		}

		string plistPath = path + "/Info.plist";
		PlistDocument plist = new PlistDocument();
		plist.ReadFromFile(plistPath);
		PlistElementDict rootDict = plist.root;
		rootDict.SetString("NSPhotoLibraryUsageDescription", "For picking photos");
		plist.WriteToFile(plistPath);
		#endif
	}
}
