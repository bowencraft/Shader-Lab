using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode, ImageEffectAllowedInSceneView]
public class ImageEffectMultiPass : MonoBehaviour
{
    public Material effectMaterial;


    void OnRenderImage (RenderTexture source, RenderTexture destination) {

    }
}
