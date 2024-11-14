﻿using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode, ImageEffectAllowedInSceneView]
public class ImageEffectBasic : MonoBehaviour {
    public Material effectMaterial;
    void OnRenderImage (RenderTexture source, RenderTexture destination) {
        Graphics.Blit(source, destination, effectMaterial);
    }
}