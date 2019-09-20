from flask import Flask, render_template, url_for, request, redirect
from flask_sqlalchemy import SQLAlchemy
from datetime import datetime

# reminder to self to launch env: source env/bin/activate

app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///test.db'
db = SQLAlchemy(app)

class Todo(db.Model):
	id = db.Column(db.Integer, primary_key=True)
	content = db.Column(db.String(200), nullable=False)
	date_created = db.Column(db.DateTime, default=datetime.utcnow)

	def __repr__(self):
		return '<Task %r>' % self.id

def basic_similarity(text1, text2):
	clean_text1 = ""
	clean_text2 = ""

	for i in range(len(text1)):
		if text1[i].isalpha() or text1[i].isspace():
			clean_text1 += text1[i]

	for i in range(len(text2)):
		if text2[i].isalpha() or text2[i].isspace():
			clean_text2 += text2[i]

	text1_split = clean_text1.split(" ")
	text2_split = clean_text2.split(" ")
	text1_set = set()
	denominator = (len(text1_split) + len(text2_split))/2 + 1
	numerator = 0

	for i in range(len(text1_split)):
		text1_set.add(text1_split[i])

	for i in range(len(text2_split)):
		if text2_split[i] in text1_set:
			numerator += 1

	return numerator/denominator


@app.route('/', methods=['POST', 'GET'])
def index():
	if request.method == 'POST':
		text1 = request.form['input-text1']
		text2 = request.form['input-text2']

		similarity = basic_similarity(text1, text2)

		new_task = Todo(content=similarity)

		try:
			db.session.add(new_task)
			db.session.commit()
			return redirect('/')
		except:
			return 'There was an issue adding your task'

	else:
		tasks = Todo.query.order_by(Todo.date_created).all()
		return render_template('index.html', tasks=tasks)


@app.route('/delete/<int:id>')
def delete(id):
	task_to_delete = Todo.query.get_or_404(id)

	try:
		db.session.delete(task_to_delete)
		db.session.commit()
		return redirect('/')
	except:
		return 'There was a problem deleting that task'


@app.route('/update/<int:id>', methods=['GET', 'POST'])
def update(id):
	task = Todo.query.get_or_404(id)

	if request.method == 'POST':
		task.content = request.form['content']

		try:
			db.session.commit()
			return redirect('/')
		except:
			return 'There was an issue updating your task'
	else:
		return render_template('update.html', task=task)


if __name__ == "__main__":
	# app.run(debug=True)
	app.run(host='0.0.0.0', debug=True)

