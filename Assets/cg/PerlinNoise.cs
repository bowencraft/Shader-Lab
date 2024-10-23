using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PerlinNoise : MonoBehaviour
{
    // change material from the renderer
    public Material material;
    public int width = 256;
    public int height = 256;
    
    public int offsetX = 0;
    public int offsetY = 0;
    
    
    void Start()
    {
        UpdateTexture();
    }
    
    void UpdateTexture()
    {
        Texture2D texture = new Texture2D(width, height);
        for (int x = 0; x < width; x++)
        {
            for (int y = 0; y < height; y++)
            {
                texture.SetPixel(x, y, CalculateColor(x, y));
            }
        }
        texture.Apply();
        material.mainTexture = texture;
    }
    
    Color CalculateColor(int x, int y) {
        float noise = Mathf.PerlinNoise(x * 0.1f, y * 0.1f);
        return new Color(noise, noise, noise);
    }
}
