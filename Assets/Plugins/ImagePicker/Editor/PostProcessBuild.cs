using UnityEditor.Callbacks;
using UnityEditor;
using UnityEditor.iOS.Xcode;
using System.IO;

public class ImagePickerFyberPostProcessBuild
{
	[PostProcessBuild]
	public static void OnPostProcessBuild(BuildTarget target, string path)
	{
		if (target != BuildTarget.iOS) {
			return;
		}

		string plistPath = path + "/Info.plist";
		PlistDocument plist = new PlistDocument();
		plist.ReadFromFile(plistPath);
		PlistElementDict rootDict = plist.root;
		rootDict.SetString("NSPhotoLibraryUsageDescription", "For picking photos");
		plist.WriteToFile(plistPath);
	}
}
