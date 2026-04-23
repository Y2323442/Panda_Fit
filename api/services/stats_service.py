from datetime import date, timedelta
from models.progress import ProgressRecord
from models.task import Task


def get_weekly_summary(user_id):
    today = date.today()
    start_day = today - timedelta(days=6)

    records = ProgressRecord.query.filter(
        ProgressRecord.user_id == user_id,
        ProgressRecord.record_date >= start_day,
        ProgressRecord.record_date <= today
    ).all()

    total_steps = sum(r.steps for r in records)
    total_minutes = sum(r.workout_minutes for r in records)
    total_distance = sum(r.distance_km for r in records)
    signed_days = sum(1 for r in records if r.signed_in)

    # ======================
    # 我新增的代码：获取签到的星期几
    # ======================
    signed_week_days = []
    for record in records:
        if record.signed_in:
            # 0 = Mon, 1 = Tue, 2 = Wed ... 6 = Sun
            week_day = record.record_date.weekday()
            signed_week_days.append(week_day)

    total_tasks = Task.query.filter_by(user_id=user_id).count()
    completed_tasks = Task.query.filter_by(user_id=user_id, status="completed").count()

    completion_rate = 0
    if total_tasks > 0:
        completion_rate = round(completed_tasks / total_tasks * 100, 2)

    return {
        "total_steps": total_steps,
        "total_minutes": total_minutes,
        "total_distance": total_distance,
        "signed_days": signed_days,
        "signed_week_days": signed_week_days,  # 👈 👈 👈 只加了这一行
        "completion_rate": completion_rate
    }