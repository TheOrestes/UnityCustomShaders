using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ObjectColor : MonoBehaviour 
{
	public Color objectColor;

	private Material[] listMaterials;
	private Material origMaterial;

	private Shader colorShader;

	// Use this for initialization
	void Start () 
	{
		listMaterials = gameObject.GetComponent<Renderer>().materials;
		//origMaterial = gameObject.GetComponent<Renderer>().material;

		colorShader = Shader.Find("Root16/colorID");
		Material colorMaterial = new Material(colorShader);
		colorMaterial.SetColor("Color_ID", objectColor);

		for(int i = 0 ; i < listMaterials.Length ; i++)
		{
			listMaterials[i] = 	colorMaterial;
		}

		//gameObject.GetComponent<Renderer>().material = colorMaterial;

		gameObject.GetComponent<Renderer>().materials = listMaterials;
	}
}
