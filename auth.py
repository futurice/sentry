from django.conf import settings
from django.contrib.auth.backends import RemoteUserBackend
from django.contrib.auth.middleware import RemoteUserMiddleware
import os

from sentry.models import (
    Organization, OrganizationMember, OrganizationMemberTeam, Team
)

class OrganizationUserBackend(RemoteUserBackend):
    def authenticate(self, remote_user):
        user = super(OrganizationUserBackend, self).authenticate(remote_user)
        if user:
            self._configure_user(user)
        return user

    def _configure_user(self, user):
        # Add everyone as part of sentry org and team
        org = Organization.objects.get(slug='sentry')
        om, _ = OrganizationMember.objects.get_or_create(
            organization=org,
            user=user,
        )
        sentry_team = Team.objects.get(slug='sentry')
        OrganizationMemberTeam.objects.get_or_create(organizationmember=om, team=sentry_team)
        return user

class ProxyHeaderMiddleware(RemoteUserMiddleware):
    header = os.getenv('REMOTE_USER_HEADER', 'HTTP_REMOTE_USER')
