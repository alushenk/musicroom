from locust import HttpLocust, TaskSet, task


class UserBehavior(TaskSet):
    def on_start(self):
        # self.client.headers['Content-Type'] = 'application/json'
        """ on_start is called when a Locust start before any task is scheduled """
        self.login()

    def on_stop(self):
        """ on_stop is called when the TaskSet is stopping """
        pass

    def login(self):
        self.client.post("/auth/login/", {"email": "wartoxy@gmail.com", "password": "q12we34rt56y"})

    @task(2)
    def index(self):
        self.client.get("/api/")

    @task(2)
    def profile(self):
        self.client.get("/auth/user")

    @task(2)
    def playlists(self):
        self.client.get("/api/playlists")

    @task(2)
    def tracks(self):
        self.client.get("/api/tracks")


class WebsiteUser(HttpLocust):
    task_set = UserBehavior
    min_wait = 5000
    max_wait = 9000
