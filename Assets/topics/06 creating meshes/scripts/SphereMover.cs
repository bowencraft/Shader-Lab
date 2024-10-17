using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SphereMover : MonoBehaviour
{
    
    public Material circleMaterial;
    public float moveSpeed = 1.0f;
    public Vector2[] circlePositions = new Vector2[10]; // 最多10个圆的位置
    public float[] circleRadii = new float[10];         
    public Color[] circleColors = new Color[10];       
    public int circleCount = 2;                         

    void Start()
    {

        UpdateCircleProperties();
    }

    void Update()
    {
        // Vector2 moveDir = new Vector2();
        Vector2 moveDir = new Vector2();
        if (Input.GetKey(KeyCode.W))
        {
            moveDir.y += 1;
        }

        if (Input.GetKey(KeyCode.S))
        {
            moveDir.y -= 1;
        }

        if (Input.GetKey(KeyCode.A))
        {
            moveDir.x -= 1;
        }

        if (Input.GetKey(KeyCode.D))
        {
            moveDir.x += 1;
        }

        moveDir.Normalize();

        
        circlePositions[0] += moveDir * moveSpeed * Time.deltaTime;

        
        ChangeFirstCircleColor();
        
        UpdateCircleProperties();
    }

    void UpdateCircleProperties()
    {
        // 设置圆的数量
        circleMaterial.SetInt("_CircleCount", circleCount);

        Vector4[] positions = new Vector4[circleCount];
        for (int i = 0; i < circleCount; i++)
        {
            positions[i] = new Vector4(circlePositions[i].x, circlePositions[i].y, 0, 0);
        }
        circleMaterial.SetVectorArray("_CirclePositions", positions);
        circleMaterial.SetFloatArray("_CircleRadii", circleRadii);

        Vector4[] colors = new Vector4[circleCount];
        for (int i = 0; i < circleCount; i++)
        {
            colors[i] = circleColors[i]; 
        }
        circleMaterial.SetVectorArray("_CircleColors", colors);
    }
    
    

    void ChangeFirstCircleColor()
    {
        float r = Mathf.Sin(Time.time * 2 * 0.5f) * 0.5f + 0.5f;
        float g = Mathf.Sin(Time.time * 2 * 0.6f + Mathf.PI / 3) * 0.5f + 0.5f; 
        float b = Mathf.Sin(Time.time * 2 * 0.7f + Mathf.PI / 6) * 0.5f + 0.5f; 

        circleColors[0] = new Color(r, g, b, 1.0f); 
    }

    
}