from models import db
from models.badge import Badge, UserBadge

LEVEL_XP = 100


def add_xp(user, xp_amount):
    user.xp += xp_amount

    # 简单学生版等级逻辑
    while user.xp >= user.level * LEVEL_XP:
        user.level += 1

    db.session.commit()


def update_streak(user, today_record):
    if today_record.signed_in:
        user.streak_days += 1
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