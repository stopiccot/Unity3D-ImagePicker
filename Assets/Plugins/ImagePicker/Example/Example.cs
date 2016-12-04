using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using System.Threading.Tasks;

public class Example : MonoBehaviour {

	public async void LoadTexture(string path) {
		if (!path.StartsWith("jar") && !path.StartsWith("file://")) {
			path = "file://" + path;
		}

		var www = new WWW(path);
		while (!www.isDone) {
			await TaskEx.FromResult(true);
		}

		GetComponent<RawImage>().texture = www.textureNonReadable;
	}

	public async void TakePhoto() {
		var path = await Stopiccot.ImagePicker.TakePhoto();

		if (!string.IsNullOrEmpty(path)) {
			Debug.Log("TakePhoto returned: \"" + path + "\"");
			LoadTexture(path);
		}
	}

	public async void SelectPhoto() {
		var path = await Stopiccot.ImagePicker.SelectPhoto();

		if (!string.IsNullOrEmpty(path)) {
			Debug.Log("SelectPhoto returned: \"" + path + "\"");
			LoadTexture(path);
		}
	}
}
