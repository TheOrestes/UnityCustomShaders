using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ReplacementShader : MonoBehaviour 
{
	public Shader replacementShader;

	// Use this for initialization
	void Start () 
	{
		GetComponent<Camera>().SetReplacementShader(replacementShader, "RenderType");	
	}
	
}
