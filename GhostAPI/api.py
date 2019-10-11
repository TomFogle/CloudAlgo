from flask import Flask, Response, render_template, url_for, request, redirect, jsonify
from flask_sqlalchemy import SQLAlchemy
import textdistance, csv

# reminder to self to launch env: source env/bin/activate

app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///test.db'
db = SQLAlchemy(app)

class Todo(db.Model):
	id = db.Column(db.Integer, primary_key=True)
	method_name = db.Column(db.String(12), nullable=False)
	distance = db.Column(db.String(10), nullable=False)
	similarity = db.Column(db.String(10), nullable=False)
	maximum = db.Column(db.String(10), nullable=False)
	norm_dist = db.Column(db.String(10), nullable=False)
	norm_sum = db.Column(db.String(10), nullable=False)
	text1 = db.Column(db.String(255), nullable=False)
	text2 = db.Column(db.String(255), nullable=False)

	def __repr__(self):
		return '<result %r>' % self.id

@app.route('/', methods=['POST', 'GET'])
def index():
	if request.method == 'POST':
		text1 = request.form['input-text1']
		text2 = request.form['input-text2']
		comp_method = request.form['option']
		distance = -69
		similarity = -69
		maximum = -69
		norm_dist = -69
		norm_sum = -69
		

		if (comp_method == "Jaro"):
			method_name = "Jaro"
			distance = str(round(textdistance.jaro.distance(text1,text2),2))
			similarity = str(round(textdistance.jaro.similarity(text1,text2),2))
			maximum = str(round(textdistance.jaro.maximum(text1,text2),2))
			norm_dist = str(round(textdistance.jaro.normalized_distance(text1,text2),2))
			norm_sum = str(round(textdistance.jaro.normalized_similarity(text1,text2),2))
		elif (comp_method == "Hamming"):
			method_name = "Hamming"
			distance = str(round(textdistance.hamming.distance(text1,text2),2))
			similarity = str(round(textdistance.hamming.similarity(text1,text2),2))
			maximum = str(round(textdistance.hamming.maximum(text1,text2),2))
			norm_dist = str(round(textdistance.hamming.normalized_distance(text1,text2),2))
			norm_sum = str(round(textdistance.hamming.normalized_similarity(text1,text2),2))
		else:
			method_name = "Levenshtein"
			distance = str(round(textdistance.levenshtein.distance(text1,text2),2))
			similarity = str(round(textdistance.levenshtein.similarity(text1,text2),2))
			maximum = str(round(textdistance.levenshtein.maximum(text1,text2),2))
			norm_dist = str(round(textdistance.levenshtein.normalized_distance(text1,text2),2))
			norm_sum = str(round(textdistance.levenshtein.normalized_similarity(text1,text2),2))

		new_task = Todo(method_name=method_name,
						distance=distance,
						similarity=similarity,
						maximum=maximum,
						norm_dist=norm_dist,
						norm_sum=norm_sum,
						text1=text1,
						text2=text2)

		try:
			db.session.add(new_task)
			db.session.commit()
			return redirect('/')
		except:
			return 'There was an issue adding your task'

	else:
		results = Todo.query.order_by(Todo.method_name).all()
		return render_template('index.html', results=results)


@app.route('/gettexts')
def gettexts():
	data = Todo.query.all()

	# with open('JarHamLevComp.csv', 'w') as out:
	# 	writer = csv.writer(out)
	# 	writer.writerow(['Method Name', 'Distance', 'Similarity', 'Maximum', 'Norm Dist', 'Norm Sum', 'Text1', 'Text2'])
	# 	writer.writerows(data)

	csv = 'Method Name, Distance, Similarity, Maximum, Norm Dist, Norm Sum, Text1, Text2'
	for dat in data:
		csv += "\n" +\
				dat.method_name + "," +\
				dat.distance + "," +\
				dat.similarity + "," +\
				dat.maximum + "," +\
				dat.norm_dist + "," +\
				dat.norm_sum + "," +\
				dat.text1 + "," +\
				dat.text2
	return Response(
		csv,
		mimetype="text/csv",
		headers={"Content-disposition":"attachment; filename=JarHamLevComp.csv"})


@app.route('/viewtexts/<int:id>', methods=['POST', 'GET'])
def viewtexts(id):
	result_to_view = Todo.query.get_or_404(id)

	if request.method == 'POST':
		return redirect('/')
	else:
		return render_template('viewtexts.html', result_to_view=result_to_view)


@app.route('/delete/<int:id>')
def delete(id):
	result_to_delete = Todo.query.get_or_404(id)

	try:
		db.session.delete(result_to_delete)
		db.session.commit()
		return redirect('/')
	except:
		return 'There was a problem deleting that task'

if __name__ == "__main__":
	# app.run(debug=True)
	app.run(host='0.0.0.0', port=8080)

