from datetime import timedelta

from models import db
from models.badge import Badge, UserBadge
from models.progress import ProgressRecord

LEVEL_XP = 30
MAX_LEVEL = 30

def add_xp(user, xp_amount):
    user.xp += xp_amount
    calculated_level = (user.xp // LEVEL_XP) + 1

    if calculated_level > user.level:
        user.level = min(calculated_level, MAX_LEVEL)

    db.session.commit()

def calculate_daily_xp(user, daily_minutes, all_tasks_done, has_signed_in):
    add_xp = 0
    hours = daily_minutes / 60

    if hours < 1:
        add_xp += 5
    elif 1 <= hours < 5:
        add_xp += 10
    else:
        add_xp += 15

    if all_tasks_done:
        add_xp += 15
    if has_signed_in:
        add_xp += 1

    add_xp(user, add_xp)
    return add_xp

def update_streak(user, today_record):
    if today_record.signed_in:
        previous_record = ProgressRecord.query.filter(
            ProgressRecord.user_id == user.id,
            ProgressRecord.signed_in.is_(True),
            ProgressRecord.record_date < today_record.record_date,
        ).order_by(ProgressRecord.record_date.desc()).first()

        if previous_record and previous_record.record_date == today_record.record_date - timedelta(days=1):
            user.streak_days += 1
        else:
            user.streak_days = 1

        user.total_sign_in_days += 1
        db.session.commit()

def try_unlock_badges(user):
    all_badges = Badge.query.all()
    owned_badge_ids = {item.badge_id for item in user.badges}
    new_badges = []

    for badge in all_badges:
        if badge.id in owned_badge_ids:
            continue

        unlocked = False
        if badge.badge_type == "streak" and user.streak_days >= badge.threshold:
            unlocked = True
        elif badge.badge_type == "xp" and user.xp >= badge.threshold:
            unlocked = True
        elif badge.badge_type == "signin" and user.total_sign_in_days >= badge.threshold:
            unlocked = True

        if unlocked:
            user_badge = UserBadge(user_id=user.id, badge_id=badge.id)
            db.session.add(user_badge)
            new_badges.append(badge.name)

    db.session.commit()
    return new_badges

# ======================
# 👇 新增：熊猫形态判断（直接粘贴在这里）
# ======================
def get_panda_stage(level):
    if level < 15:
        return "baby"      # 幼年熊猫
    elif level < 30:
        return "advanced"  # 进阶熊猫
    else:
        return "final"     # 完全体熊猫