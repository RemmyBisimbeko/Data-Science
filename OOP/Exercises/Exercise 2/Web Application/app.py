from flask import Flask, render_template, request, redirect, url_for, flash
from flask_sqlalchemy import SQLAlchemy
from datetime import datetime

app = Flask(__name__)
app.secret_key = 'your_secret_key'
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///events.db'
db = SQLAlchemy(app)

class Event(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(100), nullable=False)
    date = db.Column(db.DateTime, nullable=False)
    location = db.Column(db.String(100))
    organizer = db.Column(db.String(100), nullable=False)
    attendees = db.relationship('Attendee', backref='event', lazy=True)

class Attendee(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False)
    email = db.Column(db.String(100))
    rsvp_status = db.Column(db.String(20), nullable=False, default='Undecided')
    event_id = db.Column(db.Integer, db.ForeignKey('event.id'), nullable=False)

@app.route('/')
def index():
    events = Event.query.all()
    return render_template('index.html', events=events)

@app.route('/create_event', methods=['GET', 'POST'])
def create_event():
    if request.method == 'POST':
        title = request.form['title']
        date = datetime.strptime(request.form['date'], '%Y-%m-%d')
        location = request.form['location']
        organizer = request.form['organizer']
        new_event = Event(title=title, date=date, location=location, organizer=organizer)
        db.session.add(new_event)
        db.session.commit()
        flash('Event created successfully!', 'success')
        return redirect(url_for('index'))
    return render_template('create_event.html')

@app.route('/event/<int:event_id>', methods=['GET', 'POST'])
def event_details(event_id):
    event = Event.query.get_or_404(event_id)
    attendees = Attendee.query.filter_by(event_id=event_id).all()

    if request.method == 'POST':
        attendee_name = request.form['name']
        attendee_email = request.form['email']
        new_attendee = Attendee(name=attendee_name, email=attendee_email, event_id=event_id)
        db.session.add(new_attendee)
        db.session.commit()
        flash('RSVP submitted successfully!', 'success')
        return redirect(url_for('event_details', event_id=event_id))

    return render_template('event_details.html', event=event, attendees=attendees)

if __name__ == '__main__':
    with app.app_context():
        db.create_all()
        app.run(debug=True)
