import schedule
import time
import subprocess

def run_robot_test():
    print("Đang tiến hành tra cứu biển số xe")
    robot_file = "phatnguoi.robot"
    subprocess.run(["robot", robot_file])

schedule.every().day.at("06:00").do(run_robot_test)
schedule.every().day.at("12:00").do(run_robot_test)

last_check_time = None

while True:
    schedule.run_pending()
    if last_check_time is None or time.time() - last_check_time >= 60:
        print("Đang chờ đợi đến giờ tra cứu biển số xe...")
    last_check_time = time.time()

    time.sleep(1)