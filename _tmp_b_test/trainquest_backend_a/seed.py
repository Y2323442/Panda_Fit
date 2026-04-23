from datetime import date
from app import app
from models import db

from models.user import User
from models.task import Task
from models.progress import ProgressRecord
from models.badge import Badge
from models.photo import WorkoutPhoto


with app.app_context():
    # 为了方便演示，先清空旧数据
    Task.query.delete()
    ProgressRecord.query.delete()
    WorkoutPhoto.query.delete()
    Badge.query.delete()
    User.query.delete()

    # 创建测试用户
    user1 = User(
        username="yeli",
        email="yeli@test.com"
    )
    user1.set_password("123456")

    db.session.add(user1)
    db.session.commit()

    # 创建任务数据
    task1 = Task(
        user_id=user1.id,
        title="30 minutes moderate training",
        description="Complete 30 minutes of cardio or basic exercise",
        category="daily",
        status="pending",
        difficulty="easy",
        time_slot="7:00 AM"
    )

    task2 = Task(
        user_id=user1.id,
        title="10-minute core workout",
        description="Plank and abdominal exercises",
        category="daily",
        status="pending",
        difficulty="medium",
        time_slot="3:00 PM"
    )

    task3 = Task(
        user_id=user1.id,
        title="Run 5 km this week",
        description="Try to finish 5 km in total before weekend",
        category="project",
        status="completed",
        difficulty="medium",
        time_slot="Flexible"
    )

    # 创建今日 progress 数据
    progress1 = ProgressRecord(
        user_id=user1.id,
        record_date=date.today(),
        steps=8200,
        workout_minutes=35,
        calories=260,
        distance_km=5.1,
        signed_in=True
    )

    # 更新用户成长数据
    user1.level = 2
    user1.xp = 120
    user1.streak_days = 3
    user1.total_sign_in_days = 5

    # 创建 badge 数据
    badge1 = Badge(
        name="First Sign-in",
        description="Complete your first daily sign-in",
        threshold=1,
        badge_type="signin"
    )

    badge2 = Badge(
        name="3-Day Streak",
        description="Sign in for 3 consecutive days",
        threshold=3,
        badge_type="streak"
    )

    badge3 = Badge(
        name="100 XP Starter",
        description="Reach 100 XP",
        threshold=100,
        badge_type="xp"
    )

    db.session.add_all([task1, task2, task3, progress1, badge1, badge2, badge3])
    db.session.commit()

    print("Seed data inserted successfully.")