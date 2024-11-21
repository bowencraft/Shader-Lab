using UnityEngine;

public class OrbitCameraWithTarget : MonoBehaviour
{
    public Transform target; // 目标点
    public float distance = 10f; // 距离目标的初始距离
    public float rotationSpeed = 5f; // 旋转速度
    public float smoothing = 10f; // 缓动速度
    public Vector2 pitchLimits = new Vector2(-30f, 60f); // 上下角度限制

    private float yaw = 0f; // 水平方向的角度
    private float pitch = 0f; // 垂直方向的角度

    void Start()
    {
        // 初始化角度
        Vector3 angles = transform.eulerAngles;
        yaw = angles.y;
        pitch = angles.x;

        // 确保目标不为空
        if (target == null)
        {
            Debug.LogError("OrbitCamera: Target is not assigned.");
        }
    }

    void LateUpdate()
    {
        if (target == null) return;

        // 获取鼠标输入
        float mouseX = Input.GetAxis("Mouse X");
        float mouseY = Input.GetAxis("Mouse Y");

        // 计算目标角度
        yaw += mouseX * rotationSpeed;
        pitch -= mouseY * rotationSpeed;
        pitch = Mathf.Clamp(pitch, pitchLimits.x, pitchLimits.y);

        // 计算目标位置
        Quaternion targetRotation = Quaternion.Euler(pitch, yaw, 0);
        Vector3 targetPosition = target.position - targetRotation * Vector3.forward * distance;

        // 平滑插值移动摄像机
        transform.position = Vector3.Lerp(transform.position, targetPosition, Time.deltaTime * smoothing);
        transform.rotation = Quaternion.Slerp(transform.rotation, targetRotation, Time.deltaTime * smoothing);
    }
}