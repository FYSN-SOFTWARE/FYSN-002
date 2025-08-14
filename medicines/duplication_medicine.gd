class_name DuplicationMedicine
extends Medicine

# 使用药水
func use_medicine(owner: MedicineUI) -> void:
	Events.use_duplication_medicine.emit()
