import redis
import user_service
from datetime import date

class QuotaService:
    """ Class to manage all the quota operation for the Geocoder SQL API Extension """

    def __init__(self, logger, user_id, transaction_id, **kwargs):
        self.logger = logger
        self.user_service = user_service.UserService(logger, user_id, **kwargs)
        self.transaction_id = transaction_id

    def check_user_quota(self):
        """ Check if the current user quota surpasses the current quota """
        # TODO We need to add the hard/soft limit flag for the geocoder
        user_quota = self.user_service.get_user_quota()
        current_used = self.user_service.get_current_used_quota()
        self.logger.debug("User quota: {0} --- Current used quota: {1}".format(user_quota, current_used))
        return True if (current_used + 1) < user_quota else False

    def increment_geocoder_use(self, amount=1):
        self.user_service.increment_geocoder_use(self.transaction_id)

    def get_user_service(self):
        return self.user_service