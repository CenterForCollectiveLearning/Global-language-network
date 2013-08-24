from flask import Flask, render_template, redirect, url_for


app = Flask(__name__)


@app.route('/')
def main():
    return redirect(url_for('network'))


@app.route('/network')
@app.route('/network/<viz_type>')
@app.route('/network/<viz_type>/<data_src>')
def network(viz_type='diffusion', data_src='merged', meme_src='none', meme_name='none'):
	# select the data source for the network visualization
    return render_template('network.html', data_src=data_src, meme_src=meme_src, meme_name=meme_name)

@app.route('/network/<viz_type>/<data_src>/<meme_src>/<meme_name>')
def network(viz_type='diffusion', data_src='merged', meme_src='none', meme_name='none'):
    return render_template('network.html', data_src=data_src, meme_src=meme_src, meme_name=meme_name)

@app.route('/heatmap')
@app.route('/heatmap/<viz_type>')
@app.route('/heatmap/<viz_type>/<data_src>')
def heatmap(viz_type='diffusion', data_src='companies'):
    return render_template('heatmap.html', viz_type=viz_type, data_src=data_src)


@app.route('/about')
def about():
    return render_template('about.html')


if __name__ == '__main__':
    app.debug = True
    app.run(host='0.0.0.0')
