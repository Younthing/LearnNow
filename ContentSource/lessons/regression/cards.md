@Card(id: "regression-coef", revision: 1, sourcePage: "regression-page-1", topic: "线性回归", accent: "purple", frontTitle: "回归系数", frontSubtitle: "先看方向，再看大小", backTitle: "阅读顺序") {
回归系数的正负决定变量与目标变化的方向。

@Highlight {
方向不等于因果，仍需结合显著性和业务语境。
}
}

@Card(id: "r2", revision: 1, sourcePage: "regression-page-2", topic: "线性回归", accent: "amber", frontTitle: "R²", frontSubtitle: "解释方差，不是预测准确率", backTitle: "常见误解") {
R² 衡量模型解释目标变量波动的能力。

@Highlight {
高 R² 也可能过拟合，仍需检查残差和验证集。
}
}
