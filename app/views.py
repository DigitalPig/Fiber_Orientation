from flask import render_template, request, flash, redirect, url_for
from app import app
from werkzeug.utils import secure_filename
import numpy as np
from scipy import stats
import os.path
import os
import skimage.io as io
from skimage.color import rgb2gray
from skimage.transform import probabilistic_hough_line
from skimage.feature import canny
from io import BytesIO, StringIO
import base64
import matplotlib.pyplot as plt
from bokeh.plotting import figure, show
from bokeh.embed import components
import time

ALLOWED_EXTENSIONS = set(['png', 'jpg', 'jpeg', 'gif', 'tiff', 'tif'])


def allowed_file(filename):
    return '.' in filename and \
        filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS


def generate_plots(in_image, sigma, threshold, line_length, line_gap):
    '''
    Usage:
    generate_plots(in_image, sigma, threshold, line_width, line_gap)
    '''

    edge_image = canny(in_image, sigma)
    lines = probabilistic_hough_line(edge_image, threshold=threshold,
                                     line_length=line_length,
                                     line_gap=line_gap)
    figfile1 = StringIO()
    fig, ax = plt.subplots(1, 1)
    ax.imshow(in_image, cmap=plt.cm.gray)
    r, c = in_image.shape
    angles = []
    for line in lines:
        p0, p1 = line
        ax.plot((p0[0], p1[0]), (p0[1], p1[1]), 'r-')
        try:
            temp = np.rad2deg(np.arctan((p1[1] - p0[1]) / (p1[0] - p0[0])))
        except ZeroDivisionError:
            temp = 90
        if temp < 0:
            temp += 180
        angles.append(temp)
    ax.axis((0, c, r, 0))
    plt.savefig(figfile1, format='svg')
    figfile1_data = '<svg' + figfile1.getvalue().split('<svg')[1]
    # Let's plot the angle distribution using Bokeh
    param = stats.norm.fit(angles)
    min_x = np.min(angles)
    max_x = np.max(angles)
    axis_x = np.linspace(min_x, max_x, num=100)
    density_fun = stats.norm.pdf(axis_x, loc=param[0], scale=param[1])
    (hist_y, hist_x) = np.histogram(angles, bins=20)
    factor = np.max(hist_y) / np.max(density_fun)
    hist_bokeh = figure(title='Line Angle Distribution',
                        x_axis_label='Angles (deg)',
                        y_axis_label='Counts')
    tops = []
    bottoms = []
    lefts = []
    rights = []
    for i in range(len(hist_y)):
        tops.append(hist_y[i])
        bottoms.append(0)
        lefts.append(hist_x[i])
        rights.append(hist_x[i + 1])
    hist_bokeh.quad(top=tops, bottom=bottoms,
                    left=lefts, right=rights, line_width=2, line_color='black')
    hist_bokeh.line(axis_x, density_fun * factor, color='red')
    b_script, b_div = components(hist_bokeh)
    return figfile1_data, b_script, b_div, angles


@app.route('/', methods=['GET', 'POST'])
def index():
    need_delete = []
    if os.listdir(app.config['UPLOAD_FOLDER']) != []:
        for item in os.listdir(app.config['UPLOAD_FOLDER']):
            file_atime = os.path.getatime(os.path.join(app.config['UPLOAD_FOLDER'],
                                                       item))
            if (file_atime - time.time()) < 1800:
                need_delete.append(os.path.join(app.config['UPLOAD_FOLDER'],
                                                item))
    if len(need_delete) > 0:
        for item in need_delete:
            os.remove(item)
        need_delete = []
    if request.method == 'POST':
        # Check to see if we have the file part
        if 'file' not in request.files:
            flash('No file part')
            return redirect(request.url)
        file = request.files['file']
        if file.filename == '':
            flash('No selected file')
            return redirect(request.url)
        if file and allowed_file(file.filename):
            filename = secure_filename(file.filename)
            full_path = os.path.join(app.config['UPLOAD_FOLDER'], filename)
            file.save(full_path)
            return redirect(url_for('crop', filename=filename))
    return render_template('index.html', title='Line alignment analysis')


@app.route('/crop/<filename>', methods=['GET', 'POST'])
def crop(filename):
    if request.method == 'POST':
        x1 = request.form['x1']
        y1 = request.form['y1']
        x2 = request.form['x2']
        y2 = request.form['y2']
        return redirect(url_for('analysis', filename=filename,
                                x1=x1, y1=y1, x2=x2, y2=y2))
    return render_template('crop.html', title='crop the image',
                           analysis=False, image=filename)


@app.route('/analysis/<filename>/<x1>/<y1>/<x2>/<y2>', methods=['GET', 'POST'])
def analysis(filename, x1, y1, x2, y2):
    image_file = os.path.join(app.config['UPLOAD_FOLDER'], filename)
    x1 = int(x1)
    y1 = int(y1)
    x2 = int(x2)
    y2 = int(y2)
    bw_image = 1 - rgb2gray(io.imread(image_file)[y1:y2, x1:x2, :])
    (figfile1_data, b_script, b_div, angles) = generate_plots(bw_image,
                                                              sigma=0.5,
                                                              threshold=10,
                                                              line_length=5,
                                                              line_gap=3)
    if request.method == 'POST':
        sigma = float(request.form['sigma'])
        threshold = float(request.form['threshold'])
        line_length = float(request.form['line_length'])
        line_gap = float(request.form['line_gap'])
        (figfile1_data, b_script, b_div, angles) = generate_plots(bw_image,
                                                                  sigma=sigma,
                                                                  threshold=threshold,
                                                                  line_length=line_length,
                                                                  line_gap=line_gap)
        mean = 'Angle mean is:{0:.2f}'.format(np.mean(angles))
        std = 'Angle standard deviation is: {0:.2f}'.format(np.std(angles))
        kurtosis = 'Kurtosis is: {0:.2f}'.format(stats.kurtosis(angles))
        skewness = 'Skeness is: {0:.2f}'.format(stats.skew(angles))
        print(str(threshold))
        return render_template('analysis.html', figure1=figfile1_data, script=b_script,
                               div=b_div,
                               mean=mean,
                               std=std,
                               skewness=skewness,
                               kurtosis=kurtosis,
                               sigma_value=str(sigma),
                               thres_value=str(threshold),
                               length_value=str(line_length),
                               gap_value=str(line_gap))
    mean = 'Angle mean is:{0:.2f}'.format(np.mean(angles))
    std = 'Angle standard deviation is: {0:.2f}'.format(np.std(angles))
    kurtosis = 'Kurtosis is: {0:.2f}'.format(stats.kurtosis(angles))
    skewness = 'Skewness is: {0:.2f}'.format(stats.skew(angles))
    return render_template('analysis.html', figure1=figfile1_data, script=b_script,
                           div=b_div,
                           mean=mean,
                           std=std,
                           skewness=skewness,
                           kurtosis=kurtosis,
                           sigma_value=0.5,
                           thres_value=10,
                           length_value=5,
                           gap_value=3)
