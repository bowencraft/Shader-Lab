using UnityEngine;

public class Floating : MonoBehaviour
{
    public float waveFrequency = 0.5f;    // 与Shader中的_waveFrequency相同
    public float waveAmplitude = 0.3f;    // 与Shader中的_waveAmplitude相同
    public float waveSpeed = 1.0f;        // 与Shader中的_waveSpeed相同

    private float initialY;

    void Start()
    {
        initialY = transform.position.y;  // 记录初始位置
    }

    void Update()
    {
        // 计算浮动的Y偏移
        float offsetY = Mathf.Sin(Time.time * waveSpeed) * waveAmplitude;
        
        // 应用偏移，实现上下浮动
        transform.position = new Vector3(transform.position.x, initialY + offsetY, transform.position.z);
    }
}