from datetime import date
import os

from app import app
from models import db
from models.user import User
from models.task import Task
from models.progress import ProgressRecord
from models.badge import Badge, UserBadge
from models.photo import WorkoutPhoto


SEED_USER = {
    "username": "yeli",
    "email": "yeli@test.com",
    "password": "123456",
    "level": 2,
    "xp": 120,
    "streak_days": 3,
    "total_sign_in_days": 5,
}

SEED_TASKS = [
    {
        "title": "30 minutes moderate training",
        "description": "Complete 30 minutes of cardio or basic exercise",
        "category": "daily",
        "status": "pending",
        "difficulty": "easy",
        "time_slot": "7:00 AM",
    },
    {
        "title": "10-minute core workout",
        "description": "Plank and abdominal exercises",
        "category": "daily",
        "status": "pending",
        "difficulty": "medium",
        "time_slot": "3:00 PM",
    },
    {
        "title": "Run 5 km this week",
        "description": "Try to finish 5 km in total before weekend",
        "category": "project",
        "status": "completed",
        "difficulty": "medium",
        "time_slot": "Flexible",
    },
]

SEED_BADGES = [
    {
        "name": "First Sign-in",
        "description": "Complete your first daily sign-in",
        "threshold": 1,
        "badge_type": "signin",
    },
    {
        "name": "3-Day Streak",
        "description": "Sign in for 3 consecutive days",
        "threshold": 3,
        "badge_type": "streak",
    },
    {
        "name": "100 XP Starter",
        "description": "Reach 100 XP",
        "threshold": 100,
        "badge_type": "xp",
    },
]


def remove_seed_user_files(user_id):
    photos = WorkoutPhoto.query.filter_by(user_id=user_id).all()
    for photo in photos:
        file_path = os.path.join(app.config["UPLOAD_FOLDER"], photo.filename)
        if os.path.exists(file_path):
            os.remove(file_path)


def upsert_badge(definition):
    badge = Badge.query.filter_by(name=definition["name"]).first()
    if badge is None:
        badge = Badge(name=definition["name"])
        db.session.add(badge)

    badge.description = definition["description"]
    badge.threshold = definition["threshold"]
    badge.badge_type = definition["badge_type"]
    return badge


def seed_demo_data():
    user = User.query.filter_by(email=SEED_USER["email"]).first()
    if user is None:
        user = User(username=SEED_USER["username"], email=SEED_USER["email"])
        db.session.add(user)

    user.username = SEED_USER["username"]
    user.set_password(SEED_USER["password"])
    user.level = SEED_USER["level"]
    user.xp = SEED_USER["xp"]
    user.streak_days = SEED_USER["streak_days"]
    user.total_sign_in_days = SEED_USER["total_sign_in_days"]

    if user.id is None:
        db.session.flush()

    remove_seed_user_files(user.id)

    UserBadge.query.filter_by(user_id=user.id).delete()
    Task.query.filter_by(user_id=user.id).delete()
    ProgressRecord.query.filter_by(user_id=user.id).delete()
    WorkoutPhoto.query.filter_by(user_id=user.id).delete()

    badges = [upsert_badge(definition) for definition in SEED_BADGES]

    tasks = [
        Task(user_id=user.id, **task_definition)
        for task_definition in SEED_TASKS
    ]

    progress = ProgressRecord(
        user_id=user.id,
        record_date=date.today(),
        steps=8200,
        workout_minutes=35,
        calories=260,
        distance_km=5.1,
        signed_in=True,
    )

    db.session.add_all(tasks + [progress])
    db.session.commit()

    earned_badges = []
    for badge in badges:
        if badge.badge_type == "signin" and user.total_sign_in_days >= badge.threshold:
            earned_badges.append(UserBadge(user_id=user.id, badge_id=badge.id))
        elif badge.badge_type == "streak" and user.streak_days >= badge.threshold:
            earned_badges.append(UserBadge(user_id=user.id, badge_id=badge.id))
        elif badge.badge_type == "xp" and user.xp >= badge.threshold:
            earned_badges.append(UserBadge(user_id=user.id, badge_id=badge.id))

    db.session.add_all(earned_badges)
    db.session.commit()

    print("Seed data inserted successfully.")


if __name__ == "__main__":
    with app.app_context():
        seed_demo_data()
