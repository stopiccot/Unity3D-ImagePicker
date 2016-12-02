using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Example : MonoBehaviour {

	public async void TakePhoto() {
		var path = await Stopiccot.NativeGallery.TakePhoto();
		Debug.Log(path);
	}

	public async void SelectPhoto() {
		var path = await Stopiccot.NativeGallery.SelectPhoto();
		Debug.Log(path);
	}
}
